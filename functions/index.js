const { onDocumentDeleted } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

// When a user doc is deleted from Firestore, also delete from Firebase Auth
exports.onUserDeleted = onDocumentDeleted("users/{userId}", async (event) => {
  const userId = event.params.userId;
  try {
    await admin.auth().deleteUser(userId);
    console.log(`Successfully deleted auth user: ${userId}`);
  } catch (error) {
    console.error(`Error deleting auth user ${userId}:`, error);
  }
});
