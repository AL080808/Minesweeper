import de.bezier.guido.*;

// Declare and initialize constants NUM_ROWS and NUM_COLS = 5 (for easier testing)
private static final int NUM_ROWS = 5;
private static final int NUM_COLS = 5;
private static final int NUM_MINES = 5; // Adjust for difficulty

private MSButton[][] buttons; // 2D array of Minesweeper buttons
private ArrayList<MSButton> mines; // ArrayList of mined buttons

void setup() {
    size(400, 400);
    textAlign(CENTER, CENTER);
    
    // Make the manager
    Interactive.make(this);
    
    // Initialize buttons array
    buttons = new MSButton[NUM_ROWS][NUM_COLS];
    
    // Create MSButton objects for each row and column
    for (int r = 0; r < NUM_ROWS; r++) {
        for (int c = 0; c < NUM_COLS; c++) {
            buttons[r][c] = new MSButton(r, c);
        }
    }
    
    // Initialize the mines list
    mines = new ArrayList<MSButton>();
    
    // Set random mines
    setMines();
}

public void setMines() {
    while (mines.size() < NUM_MINES) {
        int r = (int) (Math.random() * NUM_ROWS);
        int c = (int) (Math.random() * NUM_COLS);
        
        // Ensure no duplicate mines
        if (!mines.contains(buttons[r][c])) {
            mines.add(buttons[r][c]);
        }
    }
}

public boolean isValid(int r, int c) {
    return r >= 0 && r < NUM_ROWS && c >= 0 && c < NUM_COLS;
}

public int countMines(int row, int col) {
    int numMines = 0;
    
    // Check all 8 neighboring positions
    for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
            if (dr == 0 && dc == 0) continue; // Skip the current cell
            
            int newRow = row + dr;
            int newCol = col + dc;
            
            if (isValid(newRow, newCol) && mines.contains(buttons[newRow][newCol])) {
                numMines++;
            }
        }
    }
    return numMines;
}

public boolean isWon() {
    // Check if all non-mine buttons are clicked
    for (int r = 0; r < NUM_ROWS; r++) {
        for (int c = 0; c < NUM_COLS; c++) {
            if (!mines.contains(buttons[r][c]) && !buttons[r][c].clicked) {
                return false;
            }
        }
    }
    return true;
}

public void displayWinningMessage() {
    for (int r = 0; r < NUM_ROWS; r++) {
        for (int c = 0; c < NUM_COLS; c++) {
            buttons[r][c].setLabel("WIN!");
        }
    }
}

public void displayLosingMessage() {
    for (MSButton mine : mines) {
        mine.setLabel("💣"); // Show bombs
    }
    for (int r = 0; r < NUM_ROWS; r++) {
        for (int c = 0; c < NUM_COLS; c++) {
            if (!mines.contains(buttons[r][c])) {
                buttons[r][c].setLabel("X");
            }
        }
    }
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
        if (mouseButton == RIGHT) {
            flagged = !flagged;
            if (!flagged) clicked = false; // Unflagging resets clicking
            return;
        }
        
        if (flagged || clicked) return; // Ignore flagged or already clicked buttons

        clicked = true;

        if (mines.contains(this)) {
            displayLosingMessage();
            return;
        }
        
        int surroundingMines = countMines(myRow, myCol);
        
        if (surroundingMines > 0) {
            setLabel(surroundingMines);
        } else {
            // Recursively reveal adjacent non-mined buttons
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
