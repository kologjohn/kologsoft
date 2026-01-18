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
    from: process.env.SMTP_FROM || 'KologSoft POS <no-reply@kologsoft.com>',
    replyTo: process.env.SMTP_REPLYTO || 'support@kologsoft.com',
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
      const emailSubject = process.env.KOLOGSOFT_EMAIL_SUBJECT || `Your KologSoft POS Temporary Password`;
      const appStoreLink = process.env.KOLOGSOFT_APPSTORE || 'https://example.com/appstore';
      const playStoreLink = process.env.KOLOGSOFT_PLAYSTORE || 'https://example.com/playstore';
      const supportEmail = process.env.KOLOGSOFT_SUPPORT || 'support@kologsoft.com';
      const logoUrl = process.env.KOLOGSOFT_LOGO_URL || 'https://storage.googleapis.com/kologsoft-assets/kologsoft-logo.png';

      const emailText = `Hello ${name},\n\nYour temporary password for KologSoft POS is: ${tempPassword}.\nPlease log in and change this password immediately.\n\nLogin: ${email}`;

      const emailHtml = `
        <div style="max-width:600px;margin:0 auto;font-family:'Segoe UI',Arial,sans-serif;background:#f7f9fc;border-radius:8px;padding:28px;">
          <div style="text-align:center;margin-bottom:18px;">
            <img src="${logoUrl}" alt="KologSoft POS" style="height:64px;display:block;margin:0 auto 8px;" />
            <h2 style="color:#0b3d91;margin:0;font-weight:700;">KologSoft POS</h2>
          </div>
          <div style="background:#ffffff;padding:20px;border-radius:8px;border:1px solid #eef2f6;">
            <h3 style="color:#222;margin-top:0;">Hello ${name},</h3>
            <p style="color:#333;font-size:15px;">Welcome to <strong>KologSoft POS</strong> — your point-of-sale and business management app.</p>
            <p style="color:#333;font-size:15px;">Your temporary password is:</p>
            <div style="font-size:20px;font-weight:700;color:#0b67d0;background:#eef7ff;padding:12px;border-radius:6px;text-align:center;margin:12px 0;">${tempPassword}</div>
            <p style="color:#333;font-size:14px;">Login: <strong>${email}</strong></p>
            <p style="color:#333;font-size:14px;">Please open the <strong>KologSoft POS</strong> mobile app and log in with your credentials. You will be prompted to change this password immediately for security.</p>
            <p style="margin-top:14px;font-size:14px;color:#333;">Download the app:</p>
            <p style="margin:6px 0;"><a href="${playStoreLink}">Google Play Store</a> • <a href="${appStoreLink}">App Store</a></p>
            <hr style="border:none;border-top:1px solid #f0f3f6;margin:20px 0;" />
            <p style="font-size:13px;color:#666;margin:0;">Need help? Contact our support at <a href="mailto:${supportEmail}">${supportEmail}</a></p>
          </div>
          <div style="text-align:center;color:#99a0ad;font-size:12px;margin-top:18px;">
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

// Track collection changes: update per-collection summary on create and update
// Only monitor specific collections for now
const MONITORED_COLLECTIONS = ['itemreg','stock','sales','transfer','request'];

exports.recordCollectionAdd = onDocumentCreated('{collectionId}/{docId}', async (event) => {
  try {
    const { collectionId, docId } = event.params;

    // limit to monitored collections
    if (!MONITORED_COLLECTIONS.includes(collectionId)) return null;

    const db = admin.firestore();
    const docRef = db.collection('collection_updates').doc(collectionId);

    // create a unique update id for this change
    const lastUpdateId = `${collectionId}_${docId}_${Date.now()}`;
    await docRef.set({
      collectionName: collectionId,
      lastAdded: admin.firestore.FieldValue.serverTimestamp(),
      lastDocId: docId,
      lastUpdateId,
      addedCount: admin.firestore.FieldValue.increment(1),
    }, { merge: true });

    logger.info(`Recorded add for collection ${collectionId} doc ${docId}`);
    return null;
  } catch (err) {
    logger.error('recordCollectionAdd error:', err);
    return null;
  }
});

exports.recordCollectionUpdate = onDocumentWritten('{collectionId}/{docId}', async (event) => {
  try {
    const { collectionId, docId } = event.params;

    // limit to monitored collections
    if (!MONITORED_COLLECTIONS.includes(collectionId)) return null;

    // Only treat this as an update if the document existed before
    const before = event.data?.before;
    const after = event.data?.after;

    // If no before snapshot, it's a create (handled by recordCollectionAdd)
    if (!before || !after) return null;

    const db = admin.firestore();
    const docRef = db.collection('collection_updates').doc(collectionId);

    // create a unique update id for this change
    const lastUpdateId = `${collectionId}_${docId}_${Date.now()}`;
    await docRef.set({
      collectionName: collectionId,
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      lastDocId: docId,
      lastUpdateId,
      updatedCount: admin.firestore.FieldValue.increment(1),
    }, { merge: true });

    logger.info(`Recorded update for collection ${collectionId} doc ${docId}`);
    return null;
  } catch (err) {
    logger.error('recordCollectionUpdate error:', err);
    return null;
  }
});

// Notify staff who have NOT read the latest update for a monitored collection
exports.notifyUnreadStaff = onDocumentWritten('collection_updates/{collectionId}', async (event) => {
  try {
    const { collectionId } = event.params;

    if (!MONITORED_COLLECTIONS.includes(collectionId)) return null;

    const before = event.data?.before ? event.data.before.data() : null;
    const after = event.data?.after ? event.data.after.data() : null;

    if (!after) return null;

    const newUpdateId = after.lastUpdateId || after.lastDocId || null;
    const prevUpdateId = before ? (before.lastUpdateId || before.lastDocId || null) : null;

    // only proceed when there's a new update id
    if (!newUpdateId || newUpdateId === prevUpdateId) return null;

    // Fetch all staff and notify those who don't have this update id in their readUpdates map
    const staffSnap = await admin.firestore().collection('staff').get();
    const notifyPromises = [];

    for (const doc of staffSnap.docs) {
      const staffData = doc.data() || {};
      const readUpdates = staffData.readUpdates || staffData.read_updates || {};

      // If readUpdates already contains the update id, skip
      if (readUpdates && Object.prototype.hasOwnProperty.call(readUpdates, newUpdateId)) continue;

      // Build a notification message
      const name = staffData.name || '';
      const email = staffData.email || '';
      const phone = staffData.phone || '';
      const messageText = `Hello ${name || 'Staff'}, there is a new update in ${collectionId}. Please review the changes.`;

      // send email if available
      if (email) {
        const subject = `Update: ${collectionId}`;
        notifyPromises.push(sendEmail({ to: email, subject, text: messageText, html: `<p>${messageText}</p>` }).catch(err => logger.error('email send error', err)));
      }

      // send SMS if available
      if (phone) {
        const formattedPhone = phone.startsWith('+') ? phone : `+233${phone.substring(1)}`;
        notifyPromises.push(sendSMS(messageText, formattedPhone, 'KologSoft').catch(err => logger.error('sms send error', err)));
      }
    }

    await Promise.allSettled(notifyPromises);
    logger.info(`notifyUnreadStaff: notifications sent for update ${newUpdateId} of ${collectionId}`);
    return null;
  } catch (err) {
    logger.error('notifyUnreadStaff error:', err);
    return null;
  }
});




