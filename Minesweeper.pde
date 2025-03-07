import de.bezier.guido.*;
import java.util.ArrayList;

// Declare and initialize constants NUM_ROWS and NUM_COLS = 5 for easier testing
private static final int NUM_ROWS = 5;
private static final int NUM_COLS = 5;

private MSButton[][] buttons; // 2D array of Minesweeper buttons
private ArrayList<MSButton> mines; // ArrayList of mine buttons

void setup() {
    size(400, 400);
    textAlign(CENTER, CENTER);

    // Initialize the Guido Interactive Manager
    Interactive.make(this);

    // Initialize buttons 2D array
    buttons = new MSButton[NUM_ROWS][NUM_COLS];

    // Create MSButton objects for each row and column
    for (int r = 0; r < NUM_ROWS; r++) {
        for (int c = 0; c < NUM_COLS; c++) {
            buttons[r][c] = new MSButton(r, c);
        }
    }

    // Initialize mines ArrayList
    mines = new ArrayList<MSButton>();

    // Place mines randomly
    setMines();
}

public void setMines() {
    int numMines = (NUM_ROWS * NUM_COLS) / 5; // Adjust number of mines
    while (mines.size() < numMines) {
        int row = (int) (Math.random() * NUM_ROWS);
        int col = (int) (Math.random() * NUM_COLS);

        // Ensure the mine isn't already placed
        if (!mines.contains(buttons[row][col])) {
            mines.add(buttons[row][col]);
        }
    }
}

public void draw() {
    background(0);
    if (isWon()) {
        displayWinningMessage();
    }
}

public boolean isWon() {
    for (int r = 0; r < NUM_ROWS; r++) {
        for (int c = 0; c < NUM_COLS; c++) {
            if (!mines.contains(buttons[r][c]) && !buttons[r][c].clicked) {
                return false; // Not all non-mine cells are clicked
            }
        }
    }
    return true; // Player won
}

public void displayLosingMessage() {
    for (MSButton mine : mines) {
        mine.clicked = true; // Reveal all mines
    }
    System.out.println("Game Over! You hit a mine!");
}

public void displayWinningMessage() {
    for (int r = 0; r < NUM_ROWS; r++) {
        for (int c = 0; c < NUM_COLS; c++) {
            buttons[r][c].setLabel("W"); // Indicate winning state
        }
    }
    System.out.println("Congratulations! You won!");
}

public boolean isValid(int r, int c) {
    return r >= 0 && r < NUM_ROWS && c >= 0 && c < NUM_COLS;
}

public int countMines(int row, int col) {
    int numMines = 0;
    int[][] neighbors = {{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}};

    for (int[] n : neighbors) {
        int r = row + n[0];
        int c = col + n[1];
        if (isValid(r, c) && mines.contains(buttons[r][c])) {
            numMines++;
        }
    }
    return numMines;
}

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
        Interactive.add(this); // Register it with the manager
    }

    public void mousePressed() {
        if (flagged) return; // Ignore clicks on flagged buttons
        clicked = true;

        if (mouseButton == RIGHT) {
            flagged = !flagged; // Toggle flag
            if (!flagged) clicked = false; // Unflagged cells should not be clicked
        } else if (mines.contains(this)) {
            displayLosingMessage(); // Hit a mine, game over
        } else {
            int mineCount = countMines(myRow, myCol);
            if (mineCount > 0) {
                setLabel(mineCount);
            } else {
                // Recursively reveal neighboring non-mine cells
                int[][] neighbors = {{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}};
                for (int[] n : neighbors) {
                    int r = myRow + n[0];
                    int c = myCol + n[1];
                    if (isValid(r, c) && !buttons[r][c].clicked) {
                        buttons[r][c].mousePressed();
                    }
                }
            }
        }
    }

    public void draw() {
        if (flagged) {
            fill(0);
        } else if (clicked && mines.contains(this)) {
            fill(255, 0, 0); // Red for mines
        } else if (clicked) {
            fill(200);
        } else {
            fill(100);
        }

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
