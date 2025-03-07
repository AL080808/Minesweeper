import de.bezier.guido.*;
import java.util.ArrayList;

// Updated settings for larger, harder game
private static final int NUM_ROWS = 20;
private static final int NUM_COLS = 20;
private static final int MINE_COUNT = (NUM_ROWS * NUM_COLS) / 4; // 25% of the grid will be mines

private MSButton[][] buttons;
private ArrayList<MSButton> mines;
private boolean firstClick = true; // Ensure first click is safe

void setup() {
    size(600, 600); // Adjusted to fit a 20x20 grid
    textAlign(CENTER, CENTER);
    
    Interactive.make(this);

    buttons = new MSButton[NUM_ROWS][NUM_COLS];

    for (int r = 0; r < NUM_ROWS; r++) {
        for (int c = 0; c < NUM_COLS; c++) {
            buttons[r][c] = new MSButton(r, c);
        }
    }

    mines = new ArrayList<>();
}

public void setMines(int safeRow, int safeCol) {
    mines.clear(); // Ensure no old mines exist

    while (mines.size() < MINE_COUNT) {
        int row = (int) (Math.random() * NUM_ROWS);
        int col = (int) (Math.random() * NUM_COLS);

        // Ensure mine isn't on the first clicked button or its immediate neighbors
        if (!mines.contains(buttons[row][col]) && 
            (row != safeRow || col != safeCol) &&
            !isNeighbor(safeRow, safeCol, row, col)) {
            mines.add(buttons[row][col]);
        }
    }
}

// Ensure mines don't spawn in the 3x3 area around the first click
public boolean isNeighbor(int r1, int c1, int r2, int c2) {
    return Math.abs(r1 - r2) <= 1 && Math.abs(c1 - c2) <= 1;
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
                return false;
            }
        }
    }
    return true;
}

public void displayLosingMessage() {
    for (MSButton mine : mines) {
        mine.clicked = true; // Reveal all mines
    }
    System.out.println("💥 Game Over! You hit a mine!");
}

public void displayWinningMessage() {
    for (int r = 0; r < NUM_ROWS; r++) {
        for (int c = 0; c < NUM_COLS; c++) {
            buttons[r][c].setLabel("W"); // Indicate win
        }
    }
    System.out.println("🎉 Congratulations! You won!");
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
        width = 600 / NUM_COLS;
        height = 600 / NUM_ROWS;
        myRow = row;
        myCol = col;
        x = myCol * width;
        y = myRow * height;
        myLabel = "";
        flagged = clicked = false;
        Interactive.add(this);
    }

    public void mousePressed() {
        if (flagged) return;

        // First click logic: Ensure no mine on first click
        if (firstClick) {
            setMines(myRow, myCol);
            firstClick = false;
        }

        clicked = true;

        if (mouseButton == RIGHT) {
            flagged = !flagged;
            if (!flagged) clicked = false;
        } else if (mines.contains(this)) {
            displayLosingMessage();
        } else {
            int mineCount = countMines(myRow, myCol);
            if (mineCount > 0) {
                setLabel(mineCount);
            } else {
                revealNeighbors();
            }
        }
    }

    private void revealNeighbors() {
        int[][] neighbors = {{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}};

        for (int[] n : neighbors) {
            int r = myRow + n[0];
            int c = myCol + n[1];

            if (isValid(r, c) && !buttons[r][c].clicked) {
                buttons[r][c].mousePressed();
            }
        }
    }

    public void draw() {
        if (flagged) {
            fill(0, 0, 255); // Blue for flagged cells
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
