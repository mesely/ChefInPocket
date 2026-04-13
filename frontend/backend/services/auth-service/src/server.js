const crypto = require('crypto');
const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const dotenv = require('dotenv');
const mongoose = require('mongoose');

dotenv.config();

const app = express();
const port = process.env.PORT || 5001;

app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

const userSchema = new mongoose.Schema(
  {
    fullName: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    passwordHash: { type: String, required: true }
  },
  { timestamps: true }
);

const User = mongoose.model('User', userSchema);

const hashPassword = (password) =>
  crypto.createHash('sha256').update(password).digest('hex');

async function connectDatabase() {
  await mongoose.connect(process.env.MONGODB_URI, {
    dbName: process.env.DB_NAME || 'chef_in_pocket_auth'
  });
}

async function seedUsers() {
  const count = await User.countDocuments();
  if (count > 0) {
    return;
  }

  await User.create({
    fullName: 'Jamie Parker',
    email: 'jamie@example.com',
    passwordHash: hashPassword('chef123')
  });
}

app.get('/health', (_req, res) => {
  res.json({ service: 'auth-service', status: 'healthy' });
});

app.post('/api/auth/register', async (req, res) => {
  const { fullName, email, password } = req.body;

  if (!fullName || !email || !password) {
    return res.status(400).json({ message: 'fullName, email, and password are required.' });
  }

  const existingUser = await User.findOne({ email: email.toLowerCase() });
  if (existingUser) {
    return res.status(409).json({ message: 'This email is already registered.' });
  }

  const user = await User.create({
    fullName,
    email: email.toLowerCase(),
    passwordHash: hashPassword(password)
  });

  return res.status(201).json({
    message: 'User created successfully.',
    user: {
      id: user._id,
      fullName: user.fullName,
      email: user.email
    }
  });
});

app.post('/api/auth/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: 'email and password are required.' });
  }

  const user = await User.findOne({ email: email.toLowerCase() });
  if (!user || user.passwordHash !== hashPassword(password)) {
    return res.status(401).json({ message: 'Invalid email or password.' });
  }

  return res.json({
    message: 'Login successful.',
    user: {
      id: user._id,
      fullName: user.fullName,
      email: user.email
    }
  });
});

app.get('/api/auth/profile', async (_req, res) => {
  const user = await User.findOne().sort({ createdAt: 1 });

  return res.json({
    fullName: user?.fullName || 'ChefInPocket User',
    email: user?.email || 'demo@example.com',
    savedRecipes: 24,
    publishedRecipes: 8,
    cookedMeals: 41
  });
});

async function startServer() {
  try {
    await connectDatabase();
    await seedUsers();
    app.listen(port, () => {
      console.log(`Auth service is running on port ${port}`);
    });
  } catch (error) {
    console.error('Auth service failed to start:', error.message);
    process.exit(1);
  }
}

startServer();
