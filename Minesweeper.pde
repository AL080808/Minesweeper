import de.bezier.guido.*;

// Declare and initialize constants
private static final int NUM_ROWS = 5;  // Change to 20 when ready
private static final int NUM_COLS = 5;  // Change to 20 when ready
private static final int NUM_MINES = 5;

private MSButton[][] buttons; // 2D array of minesweeper buttons
private ArrayList<MSButton> mines; // List of buttons that contain mines

void setup() {
    size(400, 400);
    textAlign(CENTER, CENTER);

    // Make the manager
    Interactive.make(this);

    // Initialize buttons array
    buttons = new MSButton[NUM_ROWS][NUM_COLS];

    // Create buttons for each row-column pair
    for (int r = 0; r < NUM_ROWS; r++) {
        for (int c = 0; c < NUM_COLS; c++) {
            buttons[r][c] = new MSButton(r, c);
        }
    }

    // Initialize the mines ArrayList
    mines = new ArrayList<MSButton>();

    // Place mines randomly
    setMines();
}

// Randomly places mines in the grid
public void setMines() {
    while (mines.size() < NUM_MINES) {
        int r = (int) (Math.random() * NUM_ROWS);
        int c = (int) (Math.random() * NUM_COLS);
        
        if (!mines.contains(buttons[r][c])) {
            mines.add(buttons[r][c]);
        }
    }
}

// Check if all non-mine buttons are clicked
public boolean isWon() {
    for (int r = 0; r < NUM_ROWS; r++) {
        for (int c = 0; c < NUM_COLS; c++) {
            if (!mines.contains(buttons[r][c]) && !buttons[r][c].clicked) {
                return false;
            }
        }
    }
    return true;
}

// Displays win message when all non-mine buttons are clicked
public void displayWinningMessage() {
    for (int r = 0; r < NUM_ROWS; r++) {
        for (int c = 0; c < NUM_COLS; c++) {
            buttons[r][c].setLabel("WIN!");
        }
    }
}

// Reveals all mines when the player clicks on one
public void displayLosingMessage() {
    for (MSButton mine : mines) {
        mine.setLabel("💣");
    }
}

// Checks if a given row, col position is valid
public boolean isValid(int r, int c) {
    return r >= 0 && r < NUM_ROWS && c >= 0 && c < NUM_COLS;
}

// Counts number of mines surrounding a given button
public int countMines(int row, int col) {
    int numMines = 0;

    // Check all 8 surrounding positions
    for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
            if (dr == 0 && dc == 0) continue; // Skip itself

            int newRow = row + dr;
            int newCol = col + dc;

            if (isValid(newRow, newCol) && mines.contains(buttons[newRow][newCol])) {
                numMines++;
            }
        }
    }
    return numMines;
}

// Button class representing a Minesweeper tile
public class MSButton {
    private int myRow, myCol;
    private float x, y, width, height;
    private boolean clicked, flagged;
    private String myLabel;

    public MSButton(int row, int col) {
        width = 400 / NUM_COLS;
        height = 400 / NUM_ROWS;
        myRow = row;
        myCol = col;
        x = myCol * width;
        y = myRow * height;
        myLabel = "";
        flagged = clicked = false;
        Interactive.add(this); // Register with Guido manager
    }

    // Handles mouse clicks
    public void mousePressed() {
        if (mouseButton == RIGHT) {
            flagged = !flagged;
            if (!flagged) clicked = false;
            return;
        }

        if (flagged || clicked) return;

        clicked = true;

        // If this is a mine, player loses
        if (mines.contains(this)) {
            displayLosingMessage();
            return;
        }

        int surroundingMines = countMines(myRow, myCol);

        if (surroundingMines > 0) {
            setLabel(surroundingMines);
        } else {
            // Reveal surrounding empty spaces
            for (int dr = -1; dr <= 1; dr++) {
                for (int dc = -1; dc <= 1; dc++) {
                    if (dr == 0 && dc == 0) continue;

                    int newRow = myRow + dr;
                    int newCol = myCol + dc;

                    if (isValid(newRow, newCol) && !buttons[newRow][newCol].clicked) {
                        buttons[newRow][newCol].mousePressed();
                    }
                }
            }
        }

        if (isWon()) {
            displayWinningMessage();
        }
    }

    // Draws the button
    public void draw() {
        if (flagged)
            fill(0);
        else if (clicked && mines.contains(this))
            fill(255, 0, 0);
        else if (clicked)
            fill(200);
        else
            fill(100);

        rect(x, y, width, height);
        fill(0);
        text(myLabel, x + width / 2, y + height / 2);
    }

    public void setLabel(String newLabel) {
        myLabel = newLabel;
    }

    public void setLabel(int newLabel) {
        myLabel = "" + newLabel;
    }

    public boolean isFlagged() {
        return flagged;
    }
}
