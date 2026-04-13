const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const dotenv = require('dotenv');
const mongoose = require('mongoose');

dotenv.config();

const app = express();
const port = process.env.PORT || 5002;

app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

const ingredientSchema = new mongoose.Schema(
  {
    name: String,
    amount: Number,
    unit: String
  },
  { _id: false }
);

const recipeSchema = new mongoose.Schema(
  {
    slug: { type: String, required: true, unique: true },
    title: { type: String, required: true },
    subtitle: String,
    description: String,
    cuisine: String,
    duration: String,
    servings: Number,
    tags: [String],
    ingredientKeys: [String],
    ingredients: [ingredientSchema],
    steps: [String],
    imageUrl: String
  },
  { timestamps: true }
);

const Recipe = mongoose.model('Recipe', recipeSchema);

const starterRecipes = [
  {
    slug: 'feta-menemen',
    title: 'Feta Menemen',
    subtitle: 'Tomatoes, onion, eggs',
    description:
      'Tomatoes, onion, eggs, and feta come together in a one-pan skillet that feels fast and comforting.',
    cuisine: 'Turkish',
    duration: '18 min',
    servings: 2,
    tags: ['Serves 2', 'One pan', 'Easy'],
    ingredientKeys: ['eggs', 'tomato', 'onion', 'oil', 'feta'],
    ingredients: [
      { name: 'Eggs', amount: 3, unit: '' },
      { name: 'Tomatoes', amount: 2, unit: '' },
      { name: 'Olive Oil', amount: 1, unit: 'tbsp' },
      { name: 'Feta', amount: 70, unit: 'g' }
    ],
    steps: [
      'Heat olive oil and soften the chopped onion.',
      'Add tomatoes and simmer until the sauce thickens.',
      'Fold in eggs and finish with feta.'
    ],
    imageUrl:
      'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=1200&q=80'
  },
  {
    slug: 'lentil-soup',
    title: 'Lentil Soup',
    subtitle: 'Comforting and quick',
    description:
      'A warm bowl with red lentils, vegetables, and lemon for a simple weeknight meal.',
    cuisine: 'Healthy',
    duration: '25 min',
    servings: 4,
    tags: ['Soup', 'Budget', 'Comfort'],
    ingredientKeys: ['lentils', 'onion', 'carrot', 'water'],
    ingredients: [
      { name: 'Red Lentils', amount: 1, unit: 'cup' },
      { name: 'Carrot', amount: 1, unit: '' },
      { name: 'Onion', amount: 1, unit: '' },
      { name: 'Water', amount: 4, unit: 'cup' }
    ],
    steps: [
      'Saute onion and carrot until they soften.',
      'Add lentils and water, then simmer for 20 minutes.',
      'Blend lightly and finish with lemon juice.'
    ],
    imageUrl:
      'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=1200&q=80'
  },
  {
    slug: 'egg-salad-bowl',
    title: 'Egg Salad Bowl',
    subtitle: 'Fresh and simple',
    description:
      'A crisp bowl with boiled eggs, greens, and a lemon yogurt dressing.',
    cuisine: 'Healthy',
    duration: '12 min',
    servings: 2,
    tags: ['Healthy', 'Fast', 'Lunch'],
    ingredientKeys: ['eggs', 'lettuce', 'cucumber', 'yogurt'],
    ingredients: [
      { name: 'Eggs', amount: 2, unit: '' },
      { name: 'Lettuce', amount: 2, unit: 'cup' },
      { name: 'Cucumber', amount: 1, unit: '' },
      { name: 'Yogurt', amount: 0.5, unit: 'cup' }
    ],
    steps: [
      'Boil the eggs for 8 minutes and cool them down.',
      'Arrange greens and sliced vegetables in a bowl.',
      'Add eggs and spoon over the yogurt dressing.'
    ],
    imageUrl:
      'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=1200&q=80'
  }
];

async function connectDatabase() {
  await mongoose.connect(process.env.MONGODB_URI, {
    dbName: process.env.DB_NAME || 'chef_in_pocket_recipe'
  });
}

async function seedRecipes() {
  const count = await Recipe.countDocuments();
  if (count > 0) {
    return;
  }

  await Recipe.insertMany(starterRecipes);
}

const formatAmount = (value) => {
  return value % 1 === 0 ? value.toString() : value.toFixed(1);
};

app.get('/health', (_req, res) => {
  res.json({ service: 'recipe-service', status: 'healthy' });
});

app.get('/api/recipes', async (_req, res) => {
  const recipes = await Recipe.find().sort({ createdAt: -1 });
  res.json(recipes);
});

app.get('/api/recipes/featured', async (_req, res) => {
  const recipe = await Recipe.findOne().sort({ createdAt: 1 });
  res.json(recipe);
});

app.post('/api/recipes/search-by-ingredients', async (req, res) => {
  const selectedIngredients = (req.body.ingredients || []).map((item) =>
    item.toLowerCase()
  );

  const recipes = await Recipe.find();
  const matches = recipes.filter((recipe) =>
    selectedIngredients.some((ingredient) =>
      recipe.ingredientKeys.includes(ingredient)
    )
  );

  res.json({
    selectedIngredients,
    results: matches
  });
});

app.get('/api/recipes/:slug', async (req, res) => {
  const recipe = await Recipe.findOne({ slug: req.params.slug });
  if (!recipe) {
    return res.status(404).json({ message: 'Recipe not found.' });
  }

  return res.json(recipe);
});

app.post('/api/recipes/:slug/scale', async (req, res) => {
  const recipe = await Recipe.findOne({ slug: req.params.slug });
  if (!recipe) {
    return res.status(404).json({ message: 'Recipe not found.' });
  }

  const servings = Number(req.body.servings || recipe.servings);
  const factor = servings / recipe.servings;

  return res.json({
    title: recipe.title,
    servings,
    scaledIngredients: recipe.ingredients.map((item) => ({
      name: item.name,
      amount: formatAmount(item.amount * factor),
      unit: item.unit
    }))
  });
});

app.post('/api/recipes/:slug/customize', async (req, res) => {
  const recipe = await Recipe.findOne({ slug: req.params.slug });
  if (!recipe) {
    return res.status(404).json({ message: 'Recipe not found.' });
  }

  const replacements = req.body.replacements || [];

  return res.json({
    message: 'Customization applied for preview.',
    recipe: recipe.title,
    replacements
  });
});

app.post('/api/recipes', async (req, res) => {
  const { title, ingredients, cuisine, prepTime, servings } = req.body;

  if (!title || !ingredients) {
    return res.status(400).json({ message: 'title and ingredients are required.' });
  }

  const slug = title.toLowerCase().replace(/[^a-z0-9]+/g, '-');
  const ingredientList = String(ingredients)
    .split(',')
    .map((item) => item.trim())
    .filter(Boolean);

  const recipe = await Recipe.create({
    slug,
    title,
    subtitle: `${ingredientList.slice(0, 3).join(', ')}`,
    description: `${title} was added from the Step 3 form.`,
    cuisine: cuisine || 'Custom',
    duration: prepTime ? `${prepTime} min` : '20 min',
    servings: Number(servings || 2),
    tags: ['Community', 'User recipe'],
    ingredientKeys: ingredientList.map((item) => item.toLowerCase()),
    ingredients: ingredientList.map((item) => ({ name: item, amount: 1, unit: '' })),
    steps: ['Add your first cooking step here.'],
    imageUrl:
      'https://images.unsplash.com/photo-1490645935967-10de6ba17061?auto=format&fit=crop&w=1200&q=80'
  });

  return res.status(201).json({
    message: 'Recipe created successfully.',
    recipe
  });
});

async function startServer() {
  try {
    await connectDatabase();
    await seedRecipes();
    app.listen(port, () => {
      console.log(`Recipe service is running on port ${port}`);
    });
  } catch (error) {
    console.error('Recipe service failed to start:', error.message);
    process.exit(1);
  }
}

startServer();
