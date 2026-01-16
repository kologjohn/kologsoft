const {onRequest} = require("firebase-functions/v2/https");
const {onDocumentCreated, onDocumentWritten} = require("firebase-functions/v2/firestore");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");
const https = require("https");
const querystring = require("querystring");
const axios = require("axios");
// const {defineString} = require("firebase-functions/params");
require('dotenv').config();
const crypto = require("crypto");
const nodemailer = require("nodemailer");
// Helper: send email with nodemailer

admin.initializeApp();

// WhatsApp API credentials via Params/Env


async function sendEmail({to, subject, text, html}) {
  const transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: process.env.SMTP_USER || "your_email@gmail.com",
      pass: process.env.SMTP_PASS || "your_app_password"
    }
  });
  const mailOptions = {
    from: process.env.SMTP_FROM || 'NWCSMS <your_email@gmail.com>',
    to,
    subject,
    text,
    html
  };
  return transporter.sendMail(mailOptions);
}

function generateNumericPassword(length = 8) {
  const digits = [];
  while (digits.length < length) {
    // crypto.randomInt provides better randomness than Math.random
    digits.push(crypto.randomInt(0, 10).toString());
  }
  return digits.join("");
}

// Helper: derive payment status from ResponseCode/Message


// Helper: SMS sending function
function sendSMS(message, contact, senderid) {
  return new Promise((resolve, reject) => {
    const apiKey = "SXlMVlJCcmlTV1dwVGRyZkVneUs";
    const params = querystring.stringify({
      action: "send-sms",
      api_key: apiKey,
      to: contact,
      from: senderid,
      sms: message,
    });

    const url = `https://sms.kologsoft.com/sms/api?${params}`;

    https
      .get(url, (res) => {
        let data = "";
        res.on("data", (chunk) => {
          data += chunk;
        });
        res.on("end", () => {
          try {
            const json = JSON.parse(data);
            resolve(json);
          } catch (e) {
            resolve(data);
          }
        });
      })
      .on("error", (err) => {
        reject(err);
      });
  });
}

// Helper: Generate bills for a workspace


// Trigger: Create Firebase Auth user when new staff is added
exports.staffAuthOnCreate = onDocumentCreated("staff/{staffId}", async (event) => {
  const staffData = event.data.data();
  const staffId = event.params.staffId;

  try {
    const email = staffData.email || `${staffData.phone}@krms.com`;
    const phone = staffData.phone || "";
    const name = staffData.name || "";
    const tempPassword = generateNumericPassword(8);

    const userRecord = await admin.auth().createUser({
      email,
      password: tempPassword,
      displayName: name,
      phoneNumber: phone ? (phone.startsWith("+") ? phone : `+233${phone.substring(1)}`) : undefined,
    });

    let smsResponse = null;
    let smsError = null;

    let emailResponse = null;
    let emailError = null;

    if (phone) {
      const formattedPhone = phone.startsWith("+") ? phone : `+233${phone.substring(1)}`;
      const smsMessage = `Hello ${name}, your temporary password for MMDA Staff Portal is: ${tempPassword}. Please log in and change this password immediately.`;
      try {
        smsResponse = await sendSMS(smsMessage, formattedPhone, "NWCSMS");
        logger.info(`SMS sent successfully to ${formattedPhone}`, smsResponse);
      } catch (err) {
        smsError = err.message;
        logger.error(`Failed to send SMS to ${formattedPhone}:`, err);
      }
    }

    // Send password via email
    if (email) {
      const emailSubject = "Your NWCSMIS Portal Temporary Password";
      const emailText = `Hello ${name},\n\nYour temporary password for MMDA Staff Portal is: ${tempPassword}.\nPlease log in and change this password immediately.\n\nLogin: ${email}`;
      // Use embedded logo (cid)
      const emailHtml = `
        <div style="max-width:500px;margin:0 auto;font-family:'Segoe UI',Arial,sans-serif;background:#f9f9f9;border-radius:10px;box-shadow:0 2px 8px #e0e0e0;padding:32px 24px;">
          <div style="text-align:center;margin-bottom:24px;">
            <img src=\"cid:nwcsmslogo@cid\" alt=\"NWCSMS Logo\" style=\"height:60px;margin-bottom:8px;\"/>
            <h2 style=\"color:#1a237e;margin:0;font-weight:700;line-height:1.2;\">National Workplace<br/>Compliance &amp; Safety<br/>Management System</h2>
          </div>
          <div style=\"background:#fff;padding:24px 20px;border-radius:8px;box-shadow:0 1px 4px #ececec;\">
            <h3 style=\"color:#263238;margin-top:0;\">Hello ${name},</h3>
            <p style=\"font-size:16px;color:#333;\">Welcome to the <b>National Workplace Compliance &amp; Safety Management System</b> app!</p>
            <p style=\"font-size:16px;color:#333;\">Your temporary password is:</p>
            <div style=\"font-size:22px;font-weight:600;color:#1565c0;background:#e3f2fd;padding:12px 0;border-radius:6px;text-align:center;letter-spacing:2px;margin:16px 0;\">${tempPassword}</div>
            <p style=\"font-size:15px;color:#444;\">Login: <b>${email}</b></p>
            <p style=\"font-size:15px;color:#444;\">Please open the National Workplace Compliance &amp; Safety Management System <b>mobile app</b> and log in with your credentials. You will be prompted to change this password immediately for your security.</p>
          </div>
          <div style=\"text-align:center;color:#888;font-size:13px;margin-top:28px;\">
            &copy; ${new Date().getFullYear()} National Workplace Compliance &amp; Safety Management System. All rights reserved.
          </div>
        </div>
      `;
      try {
        emailResponse = await sendEmail({to: email, subject: emailSubject, text: emailText, html: emailHtml});
        logger.info(`Email sent successfully to ${email}`);
      } catch (err) {
        emailError = err.message;
        logger.error(`Failed to send email to ${email}:`, err);
      }
    }

    await admin
      .firestore()
      .collection("staff")
      .doc(staffId)
      .update({
        uid: userRecord.uid,
        authCreated: admin.firestore.FieldValue.serverTimestamp(),
        tempPassword,
        smsSent: !!(phone && smsResponse),
        smsResponse: smsResponse || null,
        smsError: smsError || null,
        emailSent: !!(email && emailResponse),
        emailError: emailError || null,
      });

    logger.info(`Auth user created for staff ${name} with email ${email}`);
  } catch (error) {
    logger.error(`Error creating auth user for staff ${staffId}:`, error);
    await admin
      .firestore()
      .collection("staff")
      .doc(staffId)
      .update({
        authError: error.message,
        authCreatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
  }
});

// API Endpoint: Send SMS via POST request
exports.sendSmsApi = onRequest(async (req, res) => {
  if (req.method !== "POST") {
    return res.status(405).json({
      success: false,
      message: "Only POST requests are allowed",
    });
  }

  try {
    const {phone, message, senderid} = req.body;

    if (!phone) {
      return res.status(400).json({success: false, message: "Missing required field: phone"});
    }
    if (!message) {
      return res.status(400).json({success: false, message: "Missing required field: message"});
    }
    if (!senderid) {
      return res.status(400).json({success: false, message: "Missing required field: senderid"});
    }

    const formattedPhone = phone.startsWith("+") ? phone : `+233${phone.substring(1)}`;
    logger.info(`Sending SMS to ${formattedPhone} from ${senderid}`, {phone, senderid});

    const smsResponse = await sendSMS(message, formattedPhone, senderid);
    logger.info("SMS sent successfully", smsResponse);

    return res.status(200).json({
      success: true,
      message: "SMS sent successfully",
      response: smsResponse,
      phone: formattedPhone,
      senderid,
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    logger.error("Error sending SMS:", error);
    return res.status(500).json({
      success: false,
      message: "Failed to send SMS",
      error: error.message,
      timestamp: new Date().toISOString(),
    });
  }
});

// Generate billing for workspaces based on billingSetup
exports.generateWorkspaceBilling = onRequest(async (req, res) => {
  try {
    const billingSetupSnap = await admin.firestore().collection('billingSetup').get();
    const year = new Date().getFullYear();

    for (const billingDoc of billingSetupSnap.docs) {
      const billing = billingDoc.data();
      const { workspaceclass, amount, billingtype, id: billingSetupId, revenueitem } = billing;

      // Find all workspaces with matching workspaceClass
      const workspacesSnap = await admin.firestore()
        .collection('workspaces')
        .where('workspaceClass', '==', workspaceclass)
        .get();

      for (const wsDoc of workspacesSnap.docs) {
        const workspace = wsDoc.data();
        const workspaceId = wsDoc.id;
        const workspaceName = workspace.name || '';
        const workspaceEmail = workspace.email || '';
        const workspacePhone = workspace.phone || '';

        // Helper: send billing notification
        async function notifyBilling({deadlines, periodLabels, isQuarterly}) {
          // Email
          if (workspaceEmail && workspaceEmail.includes('@')) {
            let subject = `Invoice: ${revenueitem || 'Workspace'} - ${year}`;
            // --- CATCHY INVOICE DESIGN ---
            let html = `<div style='font-family:Segoe UI,Arial,sans-serif;max-width:600px;margin:0 auto;background:#fff;border-radius:14px;box-shadow:0 4px 24px #e0e0e0;padding:0 0 32px 0;'>`;
            html += `<div style='background:#1565c0;border-radius:14px 14px 0 0;padding:32px 24px 18px 24px;text-align:center;'>`;
            html += `<img src='https://kologsoftpos.com/coatlogo.png' alt='Ghana Coat of Arms' style='height:54px;margin-bottom:10px;'/><h1 style='color:#fff;margin:0;font-size:2.1em;letter-spacing:1px;'>INVOICE</h1>`;
            html += `<div style='color:#e3f2fd;font-size:1.1em;margin-top:8px;'>${revenueitem || 'Workspace Billing'} &bull; ${year}</div></div>`;
            html += `<div style='padding:24px 24px 0 24px;'>`;
            html += `<p style='font-size:1.1em;color:#263238;margin-bottom:8px;'>Hello <b>${workspaceName}</b>,</p>`;
            html += `<p style='color:#444;margin-top:0;'>This is your official invoice for <b>${revenueitem || 'Workspace Billing'}</b> for the year <b>${year}</b>.</p>`;
            html += `<table style='width:100%;border-collapse:collapse;margin:22px 0 18px 0;font-size:1.05em;'>`;
            html += `<tr style='background:#e3f2fd;'><th style='padding:10px 8px;border:1px solid #bbdefb;text-align:left;'>Period</th><th style='padding:10px 8px;border:1px solid #bbdefb;text-align:right;'>Amount (GHS)</th><th style='padding:10px 8px;border:1px solid #bbdefb;text-align:right;'>Deadline</th></tr>`;
            if (isQuarterly) {
              for (let i = 0; i < 4; i++) {
                html += `<tr><td style='padding:10px 8px;border:1px solid #e3f2fd;'>${periodLabels[i]}</td><td style='padding:10px 8px;border:1px solid #e3f2fd;text-align:right;'>${amount}</td><td style='padding:10px 8px;border:1px solid #e3f2fd;text-align:right;'>${deadlines[i]}</td></tr>`;
              }
            } else {
              html += `<tr><td style='padding:10px 8px;border:1px solid #e3f2fd;'>Annual</td><td style='padding:10px 8px;border:1px solid #e3f2fd;text-align:right;'>${amount}</td><td style='padding:10px 8px;border:1px solid #e3f2fd;text-align:right;'>${deadlines[0]}</td></tr>`;
            }
            html += `</table>`;
            html += `<div style='margin:18px 0 0 0;padding:16px 18px;background:#f1f8e9;border-radius:8px;color:#33691e;font-size:1.08em;'>Please ensure payment is made by the stated deadline(s).<br>For any queries, contact our office.</div>`;
            html += `<div style='margin-top:32px;text-align:center;color:#888;font-size:13px;'>&copy; ${year} National Workplace Compliance & Safety Management System</div></div></div>`;
            // --- END CATCHY DESIGN ---
            const text = `Dear ${workspaceName},\n\nThis is your invoice for ${revenueitem || 'Workspace Billing'} for the year ${year}.\n` +
              (isQuarterly
                ? periodLabels.map((p, i) => `${p}: GHS ${amount}, Deadline: ${deadlines[i]}`).join('\n')
                : `Annual: GHS ${amount}, Deadline: ${deadlines[0]}`) +
              `\n\nPlease ensure payment is made by the deadline(s).`;
            try { await sendEmail({to: workspaceEmail, subject, text, html}); } catch (e) { logger.error('Billing email error', e); }
          }
          // SMS (still per period)
          if (workspacePhone) {
            if (isQuarterly) {
              for (let i = 0; i < 4; i++) {
                const smsMsg = `Bill: GHS ${amount} for ${periodLabels[i]}. Deadline: ${deadlines[i]}.`;
                try { await sendSMS(smsMsg, workspacePhone, 'NWCSMS'); } catch (e) { logger.error('Billing SMS error', e); }
              }
            } else {
              const smsMsg = `Bill: GHS ${amount} for Annual. Deadline: ${deadlines[0]}.`;
              try { await sendSMS(smsMsg, workspacePhone, 'NWCSMS'); } catch (e) { logger.error('Billing SMS error', e); }
            }
          }
        }

        if (billingtype === 'Quarterly') {
          const deadlines = [
            `${year}-03-31`,
            `${year}-06-30`,
            `${year}-09-30`,
            `${year}-12-31`
          ];
          const periodLabels = [
            `Quarter 1, ${year}`,
            `Quarter 2, ${year}`,
            `Quarter 3, ${year}`,
            `Quarter 4, ${year}`
          ];
          for (let q = 1; q <= 4; q++) {
            const billDocId = `${billingSetupId}_${workspaceId}_Q${q}`;
            const deadline = deadlines[q - 1];
            await admin.firestore().collection('bills').doc(billDocId).set({
              workspaceId,
              workspaceName,
              workspaceClass: workspaceclass,
              amount,
              billingType: 'Quarterly',
              quarter: q,
              deadline,
              year,
              createdAt: admin.firestore.FieldValue.serverTimestamp(),
              status: 'Pending',
              billingSetupId
            });
          }
          // Send one invoice email for all quarters
          await notifyBilling({deadlines, periodLabels, isQuarterly: true});
        } else if (billingtype === 'Annually') {
          const billDocId = `${billingSetupId}_${workspaceId}_Annual`;
          const deadline = `${year}-12-31`;
          const periodLabels = [`Annual, ${year}`];
          await admin.firestore().collection('bills').doc(billDocId).set({
            workspaceId,
            workspaceName,
            workspaceClass: workspaceclass,
            amount,
            billingType: 'Annually',
            deadline,
            year,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            status: 'Pending',
            billingSetupId
          });
          await notifyBilling({deadlines: [deadline], periodLabels, isQuarterly: false});
        }
      }
    }
    res.status(200).json({ success: true, message: 'Billing generated for all workspaces.' });
  } catch (error) {
    logger.error('Error generating billing:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Firestore trigger: update workspace balance when a bill is paid
exports.updateWorkspaceBalanceOnPayment = onDocumentWritten('bills/{billId}', async (event) => {
  const after = event.data?.after?.data();
  if (!after || !after.paidamount) return;
  const workspaceId = after.workspaceId;
  const amount = after.amount || 0;
  const paidamount = after.paidamount || 0;
  const balance = amount - paidamount;
  try {
    await admin.firestore().collection('workspaces').doc(workspaceId).update({
      balance: balance
    });
  } catch (e) {
    logger.error('Failed to update workspace balance', e);
  }
});



