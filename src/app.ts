import express = require('express');
import { NextFunction, Request, Response } from 'express';
import mongoose, { Schema, Model, Document } from 'mongoose';
import * as dotenv from 'dotenv';
import * as requestIp from 'request-ip'; // Import request-ip package

dotenv.config();

// Define IP schema
interface IP extends Document {
  originalIP: string;
  reversedIP: string;
}

const IPSchema: Schema = new Schema({
  originalIP: String,
  reversedIP: String
});

const IPModel: Model<IP> = mongoose.model<IP>('IP', IPSchema);

// Connect to MongoDB
// envirnment variable will be provided through a secured mean (e.g doppler, vault)

mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/reverse_ips')
  .then(() => console.log('Connected to MongoDB'))
  .catch(err => console.error('Failed to connect to MongoDB', err));

// Define CustomRequest interface
interface CustomRequest extends Request {
  reversedIP?: string;
}

// Express app
const app = express();
const port = process.env.PORT || 3000;

// Middleware to log and save IP
function logAndSaveIP(req: CustomRequest, res: Response, next: NextFunction) {
  let originalIP = requestIp.getClientIp(req);

  const reversedIP = originalIP?.split('.').reverse().join('.');
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
app.get('/', (req: CustomRequest, res: Response) => {
  const reversedIP = req.reversedIP || ''; // Get the reversed IP from the request object
  res.send(`Origin Public IP (Reversed): ${reversedIP}`);
});

// Server
app.listen(port, () => {
  console.log(`Server is listening at http://localhost:${port}`);
});