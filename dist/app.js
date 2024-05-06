"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express = require("express");
const mongoose_1 = require("mongoose");
const dotenv = require("dotenv");
const requestIp = require("request-ip"); // Import request-ip package
dotenv.config();
const IPSchema = new mongoose_1.Schema({
    originalIP: String,
    reversedIP: String
});
const IPModel = mongoose_1.default.model('IP', IPSchema);
// Connect to MongoDB
mongoose_1.default.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/reverse_ips')
    .then(() => console.log('Connected to MongoDB'))
    .catch(err => console.error('Failed to connect to MongoDB', err));
// Express app
const app = express();
const port = process.env.PORT || 3001;
// Middleware to log and save IP
function logAndSaveIP(req, res, next) {
    let originalIP = requestIp.getClientIp(req);
    const reversedIP = originalIP === null || originalIP === void 0 ? void 0 : originalIP.split('.').reverse().join('.');
    console.log(`Origin Public IP (Reversed): ${reversedIP}`);
    // Save IP to MongoDB
    const newIP = new IPModel({ originalIP, reversedIP });
    newIP.save()
        .then(() => console.log('IP saved to MongoDB'))
        .catch(err => console.error('Failed to save IP to MongoDB', err));
    req.reversedIP = reversedIP; // Attach reversed IP to request object
    next();
}
// Routes
app.use(logAndSaveIP);
app.get('/', (req, res) => {
    const reversedIP = req.reversedIP || ''; // Get the reversed IP from the request object
    res.send(`Origin Public IP (Reversed): ${reversedIP}`);
});
// Server
app.listen(port, () => {
    console.log(`Server is listening at http://localhost:${port}`);
});
//# sourceMappingURL=app.js.map