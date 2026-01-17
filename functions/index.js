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
    from: process.env.SMTP_FROM || 'KologSoft POS <your_email@gmail.com>',
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
      const smsMessage = `Hello ${name}, your temporary password for KologSoft POS is: ${tempPassword}. Please log in and change this password immediately.`;
      try {
        smsResponse = await sendSMS(smsMessage, formattedPhone, "KologSoft");
        logger.info(`SMS sent successfully to ${formattedPhone}`, smsResponse);
      } catch (err) {
        smsError = err.message;
        logger.error(`Failed to send SMS to ${formattedPhone}:`, err);
      }
    }

    // Send password via email
    if (email) {
      const emailSubject = "Your KologSoft POS Temporary Password";
      const emailText = `Hello ${name},\n\nYour temporary password for KologSoft POS is: ${tempPassword}.\nPlease log in and change this password immediately.\n\nLogin: ${email}`;
      // Use embedded logo (cid)
      const emailHtml = `
        <div style="max-width:500px;margyein:0 auto;font-family:'Segoe UI',Arial,sans-serif;background:#f9f9f9;border-radius:10px;box-shadow:0 2px 8px #e0e0e0;padding:32px 24px;">
          <div style="text-align:center;margin-bottom:24px;">
            <img src=\"cid:kologsoftlogo@cid\" alt=\"KologSoft POS Logo\" style=\"height:60px;margin-bottom:8px;\"/>
            <h2 style=\"color:#1a237e;margin:0;font-weight:700;line-height:1.2;\">KologSoft POS</h2>
          </div>
          <div style=\"background:#fff;padding:24px 20px;border-radius:8px;box-shadow:0 1px 4px #ececec;\">
            <h3 style=\"color:#263238;margin-top:0;\">Hello ${name},</h3>
            <p style=\"font-size:16px;color:#333;\">Welcome to the <b>KologSoft POS</b> app!</p>
            <p style=\"font-size:16px;color:#333;\">Your temporary password is:</p>
            <div style=\"font-size:22px;font-weight:600;color:#1565c0;background:#e3f2fd;padding:12px 0;border-radius:6px;text-align:center;letter-spacing:2px;margin:16px 0;\">${tempPassword}</div>
            <p style=\"font-size:15px;color:#444;\">Login: <b>${email}</b></p>
            <p style=\"font-size:15px;color:#444;\">Please open the <b>KologSoft POS mobile app</b> and log in with your credentials. You will be prompted to change this password immediately for your security.</p>
          </div>
          <div style=\"text-align:center;color:#888;font-size:13px;margin-top:28px;\">
            &copy; ${new Date().getFullYear()} KologSoft POS. All rights reserved.
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




