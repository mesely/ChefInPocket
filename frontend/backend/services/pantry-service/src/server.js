const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const dotenv = require('dotenv');
const mongoose = require('mongoose');

dotenv.config();

const app = express();
const port = process.env.PORT || 5003;

app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

const ingredientSchema = new mongoose.Schema(
  {
    ingredientId: { type: String, required: true, unique: true },
    title: String,
    emoji: String
  },
  { timestamps: true }
);

const groceryItemSchema = new mongoose.Schema(
  {
    title: { type: String, required: true },
    note: String,
    emoji: String
  },
  { timestamps: true }
);

const PantryIngredient = mongoose.model('PantryIngredient', ingredientSchema);
const GroceryItem = mongoose.model('GroceryItem', groceryItemSchema);

const starterIngredients = [
  { ingredientId: 'eggs', title: 'Eggs', emoji: '🥚' },
  { ingredientId: 'tomato', title: 'Tomato', emoji: '🍅' },
  { ingredientId: 'onion', title: 'Onion', emoji: '🧅' },
  { ingredientId: 'oil', title: 'Olive oil', emoji: '🫒' },
  { ingredientId: 'garlic', title: 'Garlic', emoji: '🧄' },
  { ingredientId: 'pepper', title: 'Pepper', emoji: '🌶️' },
  { ingredientId: 'potato', title: 'Potato', emoji: '🥔' },
  { ingredientId: 'milk', title: 'Milk', emoji: '🥛' }
];

const starterGroceryItems = [
  { title: 'Eggs', note: 'Need 2 more', emoji: '🥚' },
  { title: 'Tomatoes', note: 'Need 4 more', emoji: '🍅' },
  { title: 'Feta', note: 'Need 1 pack', emoji: '🧀' }
];

async function connectDatabase() {
  await mongoose.connect(process.env.MONGODB_URI, {
    dbName: process.env.DB_NAME || 'chef_in_pocket_pantry'
  });
}

async function seedPantry() {
  if ((await PantryIngredient.countDocuments()) === 0) {
    await PantryIngredient.insertMany(starterIngredients);
  }

  if ((await GroceryItem.countDocuments()) === 0) {
    await GroceryItem.insertMany(starterGroceryItems);
  }
}

app.get('/health', (_req, res) => {
  res.json({ service: 'pantry-service', status: 'healthy' });
});

app.get('/api/pantry/ingredients', async (_req, res) => {
  const ingredients = await PantryIngredient.find().sort({ createdAt: 1 });
  res.json(ingredients);
});

app.post('/api/pantry/match', async (req, res) => {
  const selected = req.body.ingredients || [];
  const recommendations = [];

  if (selected.includes('eggs') && selected.includes('tomato')) {
    recommendations.push('feta-menemen');
  }

  if (selected.includes('eggs') && selected.includes('lettuce')) {
    recommendations.push('egg-salad-bowl');
  }

  if (selected.includes('lentils')) {
    recommendations.push('lentil-soup');
  }

  res.json({
    selected,
    recommendedRecipeSlugs: recommendations
  });
});

app.get('/api/pantry/grocery-list', async (_req, res) => {
  const items = await GroceryItem.find().sort({ createdAt: 1 });
  res.json(items);
});

app.post('/api/pantry/grocery-list', async (req, res) => {
  const { title, note, emoji } = req.body;

  if (!title) {
    return res.status(400).json({ message: 'title is required.' });
  }

  const item = await GroceryItem.create({
    title,
    note: note || 'Added manually',
    emoji: emoji || '🛒'
  });

  return res.status(201).json({
    message: 'Grocery item added.',
    item
  });
});

app.delete('/api/pantry/grocery-list/:id', async (req, res) => {
  const item = await GroceryItem.findByIdAndDelete(req.params.id);
  if (!item) {
    return res.status(404).json({ message: 'Grocery item not found.' });
  }

  return res.json({
    message: 'Grocery item removed.',
    removedId: item._id
  });
});

async function startServer() {
  try {
    await connectDatabase();
    await seedPantry();
    app.listen(port, () => {
      console.log(`Pantry service is running on port ${port}`);
    });
  } catch (error) {
    console.error('Pantry service failed to start:', error.message);
    process.exit(1);
  }
}

startServer();
