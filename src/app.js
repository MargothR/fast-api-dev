const express = require(`express`)
const app = express()
app.use(express.json())

const items = [
  { id: 1, name: `Laptop`, price: 1500, stock: 10 },
  { id: 2, name: `Mouse`, price: 25, stock: 50 },
  { id: 3, name: `Teclado`, price: 45, stock: 30 }
]

app.get(`/health`, (req, res) => {
  res.status(200).json({ status: `OK` })
})

app.get(`/items`, (req, res) => {
  res.status(200).json(items)
})

module.exports = app
