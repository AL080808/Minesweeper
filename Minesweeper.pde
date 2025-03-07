import de.bezier.guido.*;
import java.util.ArrayList;

// BIGGER GRID AND NO MINE ON FIRST CLICK
private static final int NUM_ROWS = 16;
private static final int NUM_COLS = 16;
private static final int MINE_COUNT = (NUM_ROWS * NUM_COLS) / 5; // 20% of the grid

private MSButton[][] buttons;
private ArrayList<MSButton> mines;
private boolean firstClick = true; // Track the first click

void setup() {
    size(640, 640); // Bigger grid, bigger screen
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

        // Ensure the mine isn't on the first clicked button
        if (!mines.contains(buttons[row][col]) && (row != safeRow || col != safeCol)) {
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
                return false;
            }
        }
    }
    return true;
}

public void displayLosingMessage() {
    for (MSButton mine : mines) {
        mine.clicked = true;
    }
    System.out.println("💥 Game Over! You hit a mine!");
}

public void displayWinningMessage() {
    for (int r = 0; r < NUM_ROWS; r++) {
        for (int c = 0; c < NUM_COLS; c++) {
            buttons[r][c].setLabel("W");
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
        width = 640 / NUM_COLS;
        height = 640 / NUM_ROWS;
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

        // First click logic: Ensure it's never a mine
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
            fill(0, 0, 255); // Blue for flags
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
