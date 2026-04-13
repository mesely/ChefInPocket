const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const dotenv = require('dotenv');
const mongoose = require('mongoose');

dotenv.config();

const app = express();
const port = process.env.PORT || 5005;

app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

const messageSchema = new mongoose.Schema(
  {
    context: String,
    sender: String,
    text: String
  },
  { timestamps: true }
);

const AssistantMessage = mongoose.model('AssistantMessage', messageSchema);

const starterMessages = [
  {
    context: 'Menemen',
    sender: 'assistant',
    text: 'I see you are making Menemen. Want help adjusting the recipe?'
  },
  {
    context: 'Menemen',
    sender: 'user',
    text: 'Make it spicier.'
  },
  {
    context: 'Menemen',
    sender: 'assistant',
    text: 'Add chili flakes and a little extra garlic near the end.'
  }
];

async function connectDatabase() {
  await mongoose.connect(process.env.MONGODB_URI, {
    dbName: process.env.DB_NAME || 'chef_in_pocket_assistant'
  });
}

async function seedMessages() {
  if ((await AssistantMessage.countDocuments()) === 0) {
    await AssistantMessage.insertMany(starterMessages);
  }
}

function buildReply(message) {
  const text = message.toLowerCase();

  if (text.includes('spicy') || text.includes('spicier')) {
    return 'Use chili flakes and finish with black pepper to bring more heat.';
  }

  if (text.includes('replace') || text.includes('swap')) {
    return 'Roasted peppers or canned tomatoes both work as easy replacements.';
  }

  if (text.includes('cook')) {
    return 'Keep the heat medium and stir gently after adding the eggs.';
  }

  return 'That sounds good. Taste as you go and keep the pan at medium heat.';
}

app.get('/health', (_req, res) => {
  res.json({ service: 'assistant-service', status: 'healthy' });
});

app.get('/api/assistant/history', async (req, res) => {
  const context = req.query.context || 'Menemen';
  const history = await AssistantMessage.find({ context }).sort({ createdAt: 1 });
  res.json(history);
});

app.post('/api/assistant/message', async (req, res) => {
  const { context = 'General', message } = req.body;

  if (!message) {
    return res.status(400).json({ message: 'message is required.' });
  }

  const reply = buildReply(message);

  const storedMessages = await AssistantMessage.insertMany([
    { context, sender: 'user', text: message },
    { context, sender: 'assistant', text: reply }
  ]);

  return res.json({
    message: 'Reply generated.',
    reply,
    storedMessages
  });
});

async function startServer() {
  try {
    await connectDatabase();
    await seedMessages();
    app.listen(port, () => {
      console.log(`Assistant service is running on port ${port}`);
    });
  } catch (error) {
    console.error('Assistant service failed to start:', error.message);
    process.exit(1);
  }
}

startServer();
