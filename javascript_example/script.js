var canvas = document.getElementById("canvas");
var ctx = canvas.getContext('2d');
ctx.beginPath();

var mapSize = 20;
var cellSize = 15;
var size = mapSize * cellSize;

var TYPES = {
  NONE: 0,
  RESIDENTIAL: 1,
  COMMERCIAL: 2,
  INDUSTRIAL: 3,
  ROAD: 7
}

function RandomRange(min, max) {
  return Math.random() * (max - min) + min;
}

function getRandomColor() {
  var letters = '0123456789ABCDEF';
  var color = '#';
  for (var i = 0; i < 6; i++) {
    color += letters[Math.floor(Math.random() * 16)];
  }
  return color;
}

function Cell(i, j) {
  this.i = i;
  this.j = j;
  this.type = TYPES.NONE;
  this.id = -1;
  this.color = "";
}

function setId(i, j, id) {
  if (i < mapSize && j < mapSize) {
    grid[i][j].id = id;
  }
}

function shuffle(array) {
  var copy = [],
    n = array.length,
    i;

  // While there remain elements to shuffle…
  while (n) {

    // Pick a remaining element…
    i = Math.floor(Math.random() * array.length);

    // If not already shuffled, move it to the new array.
    if (i in array) {
      copy.push(array[i]);
      delete array[i];
      n--;
    }
  }

  return copy;
}

// Get all cells as a 1 dimensional array
function GetAllCells() {
  var cells = [];
  for (var i = 0; i < mapSize; i+=2) {
    for (var j = 0; j < mapSize; j+=2) {
      cells.push(grid[i][j]);
    }
  }
  return cells;
}

function getType(i, j) {
  return grid[i][j].id % 5;
}

function getCell(i, j) {
  return grid[i][j];
}

function getNeighbors(i, j) {
  var neighbors = [];

  if (IsInBounds(i - 1, j))
    neighbors.push(getCell(i - 1, j));
  if (IsInBounds(i + 1, j))
    neighbors.push(getCell(i + 1, j));
  if (IsInBounds(i, j - 1))
    neighbors.push(getCell(i, j - 1));
  if (IsInBounds(i, j + 1))
    neighbors.push(getCell(i, j + 1));

  return neighbors;
}

function IsInBounds(i, j) {
  return !(i < 0 || i >= mapSize || j < 0 || j >= mapSize);
}

// Check if the neighbor to the right or below is a road and if so replace self as a road cell
function checkIfRoad(i, j) {
  if (IsInBounds(i + 1, j) && grid[i + 1][j].id != grid[i][j].id) {
    grid[i][j].type = TYPES.ROAD;
  }

  if (IsInBounds(i, j + 1) && grid[i][j + 1].id != grid[i][j].id) {
    grid[i][j].type = TYPES.ROAD;
  }
}

// Convert type to a color
function getColor(zone) {
  if (zone == TYPES.RESIDENTIAL) {
    return "#00FF00";
  }
  if (zone == TYPES.COMMERCIAL) {
    return "#0000FF";
  }
  if (zone == TYPES.INDUSTRIAL) {
    return "#FF0000";
  }
  if (zone == TYPES.ROAD) {
    return "#303030";
  }
}

// Generate the grid
var grid = [];

for (var i = 0; i < mapSize; i++) {
  grid[i] = [];
  for (var j = 0; j < mapSize; j++) {
    grid[i][j] = new Cell(i, j);
  }
}

// Get a random order to loop through the cells
var checkOrder = shuffle(GetAllCells());
var minSize = 4;
var maxSize = 10;

for (var id = 1; id < checkOrder.length; id++) {
  var curTile = checkOrder[id];

  if (curTile.type == TYPES.NONE) {
    var direction = (Math.random() > .5 ? 1 : 0);
    var square_width = RandomRange(minSize, (direction ? maxSize : minSize));
    var square_height = RandomRange(minSize, (direction ? minSize : maxSize));

    var zones = [TYPES.RESIDENTIAL, TYPES.COMMERCIAL, TYPES.COMMERCIAL, TYPES.RESIDENTIAL, TYPES.INDUSTRIAL];
    var zone = zones[Math.floor(Math.random() * zones.length)];
    var color = getRandomColor();

    for (var i = 0; i < square_width; i+=2) {
      for (var j = 0; j < square_height; j+=2) {
        if (IsInBounds(curTile.i + i+1, curTile.j + j+1)) {
          grid[curTile.i + i][curTile.j + j].id = id;					// [x] O
          grid[curTile.i + i][curTile.j + j].type = zone;		 	//	O  O
          
          grid[curTile.i + i+1][curTile.j + j].id = id;		 	 	//	x [O]
          grid[curTile.i + i+1][curTile.j + j].type = zone;	 	//	O  O
          
          grid[curTile.i + i][curTile.j + j+1].id = id;				//	x  O
          grid[curTile.i + i][curTile.j + j+1].type = zone;	 	// [O] O
          
          grid[curTile.i + i+1][curTile.j + j+1].id = id;     //  x  O 
          grid[curTile.i + i+1][curTile.j + j+1].type = zone;	// 	O [O]
        }
      }
    }
  }
}

// Update the size of the canvas
ctx.canvas.width = size;
ctx.canvas.height = size;

// Draw the cells on the canvas
for (var i = 0; i < mapSize; i++) {
  for (var j = 0; j < mapSize; j++) {
    checkIfRoad(i, j);
    ctx.fillStyle = getColor(grid[i][j].type);
    ctx.fillRect(i * cellSize, j * cellSize, cellSize, cellSize);
  }
}