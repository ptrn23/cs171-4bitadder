#import "template.typ": *
#show: template

= Introduction
== Problem Definition
While numerous digital Sudoku solvers exist, the majority rely on brute-force algorithms, such as recursive backtracking @bhattarai-algorithms. These algorithms solve the puzzle instantly but offer zero educational value to the player, producing the final state without explaining the logical steps required to reach the solution. 

Furthermore, to establish the boundaries of the problem, Sudoku is formulated as a Constraint Satisfaction Problem (CSP) where an 81-cell grid (9x9) must be populated with integers 1 through 9. This problem compounds when introducing variants:
- *Standard Sudoku:* Every row, column, and 3x3 subgrid must contain the digits 1 through 9 exactly once.
- *X-Sudoku:* A geometric constraint where the two main diagonals must also contain unique digits 1 through 9.
- *Killer Sudoku:* A mathematical constraint containing "cages" where the sum of the digits must equal a target number, and digits cannot repeat within a cage.

== Objective
To address this educational gap, we introduce _SudoKurious_, an interactive AI tutor. The objective of this application is to evaluate the current board state and provide context-aware, step-by-step hints based on human-understandable logic (e.g., "Naked Singles" or "Hidden Singles"), translating complex heuristics into a high-level, user-friendly tutoring interface.

== Project Scope
The final prototype includes support for three Sudoku variants (Standard, X, and Killer). It features a heuristic expert system for logic deduction, a Local Search-based Genetic Algorithm (LSGA) fallback for complex grid states, and a machine learning difficulty regression predictor. It also features a fully interactive UI with personalized AI tutoring profiles.

= Related Work
While academic research exists on using heuristic steps that mimic human-like logic techniques @pillay-heuristics, there is a distinct lack of tools that translate these heuristics into a consumer-facing application. Existing platforms focus on generating puzzles or solving them entirely. _SudoKurious_ differentiates itself by prioritizing the educational feedback loop, acting as a tutor that walks the user through the CSP step-by-step rather than just a calculator.

= Data Acquisition and Preprocessing
== Dataset Description
To train the difficulty prediction model and validate the heuristic expert system, we used a publicly available dataset of #link("https://www.kaggle.com/datasets/radcliffe/3-million-sudoku-puzzles-with-ratings")[#underline[*3 million Sudoku puzzles*]] sourced from Kaggle. Each dataset entry provides a flat 81-character string representation of the puzzle, its solution, the number of starting clues (ranging from 19 to 31), and a raw difficulty rating (ranging from 0.0 to 8.5) calculated based on the average search tree depth required by an automated solver.

#figure(
  image("images/not_iso.png", width: 80%),
  caption: [
    Example of a parsed 9x9 Sudoku grid from the dataset string:  

    `.467....5.3.......5....93..`
    `4....1...39...258........29`
    `1...2.76....5.8...86.......`],

)

== Data Preprocessing Pipeline
A significant portion of the raw dataset (43%) had a difficulty of zero. To prevent the machine learning model from developing a bias toward these simple puzzles, we applied an under-sampling technique, reducing the zero-difficulty samples to achieve a 1:1 ratio. 

For the model to properly interpret the grids, strings were transformed into numerical arrays using One-Hot Encoding to map the board states into 3D tensors. This prevents the regression model from falsely interpreting the Sudoku digits as continuous mathematical values. Furthermore, target difficulty scores were normalized using Min-Max scaling to map the original 0--8.5 range to a more intuitive 1--5 scale.

== Data Split
The dataset was partitioned using a strict 80/20 train-test split, allowing the system to accurately monitor the Mean Absolute Error (MAE) during the validation phase.

#academic-table(
  columns: 2,
  caption: [Dataset Characteristics and Preprocessing Summary],
  table.header(
    [*Attribute*], [*Details*],
  ),
  [Source], [Kaggle (3-Million Sudoku Puzzles)],
  [Total Puzzles], [3,000,000 (pre-sampling)],
  [Clue Range], [19 to 31 clues per board],
  [Raw Difficulty], [0.0 to 8.5 (Search Tree Depth)],
  [Scaled Difficulty], [1.0 to 5.0 (Min-Max Scaling)],
  [Rebalancing], [Zero-difficulty under-sampled (1:1 ratio)],
  [Data Structure], [One-Hot Encoded 3D Tensors],
  [Data Split], [80% Training / 20% Testing],

)

= Methodology & Technical Approach
== System Architecture
The architecture of _SudoKurious_ is designed around the principles of an intelligent tutoring agent. To formalize the system's design, we define the AI agent using the PEAS framework: Performance (hint accuracy, < 2s latency), Environment (the 9x9 grid constraints), Actuators (dynamic UI highlighters), and Sensors (API payloads capturing user inputs).

#figure(
  image("images/4bit_iso.png", width: 100%),
  caption: [High-level architecture diagram between the user, Next.js UI, Python API, and the 3 AI models.],
)

== Model Selection
To meet the goals of _SudoKurious_, our system uses three different models working together, with each handling a specific part of the problem.

For predicting puzzle difficulty, we first looked into deep learning methods like Convolutional Neural Networks (CNNs) and Graph Neural Networks (GNNs). However, CNNs do not work well for Sudoku because the game's rules are not just about physical distance on the board, and GNNs are simply too slow for computing needs. Because of this, we switched to an Advanced Random Forest model. Simply put, this model creates hundreds of virtual "decision trees" that each vote on how hard a puzzle is based on its features. This method is fast, easy to understand, and works perfectly with our data format.

#figure(
  image("images/4bit_iso.png", width: 100%),
  caption: [Diagram illustrating how the Random Forest uses multiple decision trees to vote on and predict a puzzle's difficulty. @trendspider-rf],
)

To act as an effective educational tutor, our main logic engine works by following human-like rules @jilg-carter-sudoku. Instead of just instantly calculating the final answer, this engine uses common Sudoku strategies (like finding "Naked Singles" or "Hidden Pairs") to figure out the next best move. This allows the system to explain its choices to the user in plain English, teaching them how to play rather than just solving the board for them.

Finally, some puzzle states are too complex for basic rules especially in Killer Sudoku, where mathematical constraints often cause normal human strategies to get stuck. For these boards, the system uses a Local Search-based Genetic Algorithm (LSGA) as a backup. This algorithm steps in to crunch the numbers and solve the hardest constraints, and then hands control back to the logic engine so it can continue tutoring the user.

== Training Process
Because our system uses different types of AI models, we trained them on different computers. After training, the finished models were uploaded to the Render platform to run in the cloud.

=== Random Forest Regression Training
We trained the difficulty predictor on a local computer using the Python `scikit-learn` library. We used a set of 500,000 puzzles, extracting seven key features that represent how humans think about Sudoku (like the mathematical "Search Space"). 

To prevent the model from just memorizing the puzzles (overfitting), we carefully set its learning limits. We created 150 virtual decision trees and limited each tree to a depth of 15 steps.

The exact settings used to train the Random Forest are detailed in the tables below.

#academic-table(
  columns: (1fr, 1fr),
  caption: [Random Forest Training Parameters],
  table.header(
    [*Parameter*], [*Value*],
  ),
  [Training Subset], [500,000 puzzles],
  [`n_estimators`], [150],
  [`max_depth`], [15],
  [`n_jobs`], [-1],
)

Random Forest models run better on standard processors (CPUs) than on graphics cards (GPUs). By splitting the work across all available CPU cores, the model trained incredibly fast, finishing in just 13.63 seconds. 

#academic-table(
  columns: 2,
  caption: [Hardware Specifications: Random Forest Training Environment],
  table.header(
    [*Component*], [*Specification*],
  ),
  [Processor (CPU)], [AMD Ryzen 7 5700G (3.80 GHz)],
  [Memory (RAM)], [16.0 GB (3200 MHz)],
  [Graphics (GPU)], [AMD Radeon(TM) Graphics (2 GB Integrated)],
  [Storage], [466 GB Total / 344 GB Used],
)

=== Genetic Algorithm (LSGA)
Unlike the Random Forest, the Local Search-based Genetic Algorithm (LSGA) operates dynamically. It is entirely based on Wang et al. (2023) paper on Column and Sub-Block Local Search for Sudoku puzzles. It is an optimization search that runs entirely at runtime on the Render cloud backend whenever a complex grid exhausts the standard heuristics. Therefore, this model were tuned to ensure it could resolve boards within the strict $<$ 2-second cloud latency limit.

The algorithm mirrors biological evolution. It generates a "population" of 200 random, partially filled boards. A fitness function scores each board based on how many Sudoku rules it breaks (fewer errors equal a better score). The worst boards are discarded, while the "elite" boards are combined (crossover) and slightly altered (mutation) to create a new generation of solutions. Crucially, we integrated a "Local Search" function that attempts small, greedy swaps on conflicting cells, elevating this from a standard GA to a highly efficient Memetic Algorithm.

#figure(
  image("images/4bit_iso.png", width: 100%),
  caption: [Crossover between two individuals. @wang-lsga],
)

To maintain the application's goal of being an educational tutor rather than just an instant solver, the LSGA uses a custom "Hall of Fame" mechanic. As the algorithm evolves, it saves the top 50 near-perfect boards (boards with $< 4$ errors). Instead of immediately revealing the final solved state, the system scans this Hall of Fame for a "consensus", a specific empty cell where every near-perfect board mathematically agrees on the same digit. This allows the AI to provide a highly confident, localized hint to the user without giving away the entire puzzle.

The finalized parameters deployed to the Render backend are detailed in the table below.

#academic-table(
  columns: (1.5fr, 1fr),
  caption: [LSGA Hyperparameters ],
  table.header(
    [*Parameter*], [*Value*],
  ),
  [Population Size (`pop_size`)], [250],
  [Max Generations], [1,000],
  [Elite Count], [30%],
)
=== Heuristic Algorithm
Another way a Sudoku puzzle is solved is through heuristic ways or current techniques used in solving Sudoku puzzles. For ease of comprehension, the following terms are referenced in the following section:
- *Unit:* A block, column or row in a Sudoku where the rules of unique numbers must be followed.
- *Candidate:* A number or numbers that can be potentially placed in a Sudoku cell. 
- *Naked Pair:* Where in a unit, 2 cells contain the same pair of candidate numbers. 
- *Naked Triples:* Same definition as a Naked Pair instead, 3 cells contain the same 3 candidate numbers.

Techniques used in implementing the heuristic algorithm are from the easy to intermediate difficulty such as: 
- *Naked Singles:* A number can only be placed in one cell in a unit.
- *Hidden Singles:* Only one candidate number is present in a cell.

From these techniques, ways to eliminate possible candidates in a cell to achieve a hidden single are also implemented such as:
- *Naked Pair/Triples Elimination:* If a Naked Pair/Triples is present in a shared unit(the same block, row or column), the pair/triples of candidate numbers should appear in these cells only. Therefore eliminating redundant candidate numbers.
- *Pointing Pairs/Triples:* When a candidate number is in only 2 or 3 cells in a block and those cells share the same row or column, any other same candidate number the cells are pointing to are eliminated. 

The order by which the heuristic algorithm chooses which technique to use first is from the easiest(Naked Singles) to the hardest(Hidden Singles) just as the A-star algorithm chooses which move is the best. With the difficulty of the technique as the cost of the move and if a new valid number is marked in the Sudoku puzzle is seen as being closer to the goal. 

If all regular techniques are exhausted, the algorithm will fill the Sudoku board with all candidate numbers and use the candidate number elimination techniques above to find a hidden single.  

= Evaluation and Results

== Metrics
To measure how well our difficulty predictor works, we used two standard mathematical metrics:
- *Mean Absolute Error (MAE):* This calculates the average difference between the AI's predicted difficulty and the actual difficulty. Since our system uses a 1-to-5 scale, MAE tells us exactly how many "points" off the prediction is on average.
- *R-squared (R2 Score):* This measures how much of the puzzle's difficulty can be explained by the features we extracted. 

== Results
The model was evaluated against our 20% testing dataset. The overall performance and the importance of each feature are detailed in the tables below.

#academic-table(
  columns: (1.5fr, 1fr),
  caption: [Random Forest Evaluation Statistics],
  table.header(
    [*Metric*], [*Result*],
  ),
  [Mean Absolute Error (MAE)], [0.4974],
  [R-squared (R2 Score)], [0.0491],
  [Model Training Time], [13.63 seconds],
)

#academic-table(
  columns: (1.5fr, 1fr),
  caption: [Feature Importance Ranking],
  table.header(
    [*Extracted Feature*], [*Influence Weight*],
  ),
  [Log Search Space], [46.39%],
  [Naked Singles], [30.98%],
  [Average Candidates], [15.00%],
  [Maximum Candidates], [3.71%],
  [Total Clues], [3.65%],
  [Easy Zones], [0.20%],
  [Minimum Candidates], [0.08%],
)

#figure(
  image("images/4bit_iso.png", width: 100%),
  caption: [Bar chart visualizing the influence of Search Space and Naked Singles compared to raw Clue Count.],
) <feature-importance>

== Discussion
=== Random Forest
The Random Forest model achieved a Mean Absolute Error of 0.4974. Because our application rates puzzles on a 1.0 to 5.0 scale, an MAE of roughly 0.5 means the AI is usually only half a point away from the true difficulty. This is highly accurate for a consumer-facing app, as it successfully groups puzzles into correct broad categories (like Easy vs. Medium) without confusing the user.

The feature ranking also proves that the AI learned to evaluate puzzles like a human. Originally, one might assume that having fewer "Total Clues" makes a puzzle harder. However, the model discovered that the "Log Search Space" (how many possible mathematical combinations exist) and "Naked Singles" (how many obvious moves are available) make up over 77% of what actually makes a puzzle difficult as seen in @feature-importance. Total Clues only accounted for 3.65% of the difficulty weight.

Because the Random Forest uses this simple tabular data instead of processing heavy images, it makes predictions almost instantly.

=== LSGA & Heuristic Algorithm
For a more user-friendly approach to solving a Sudoku puzzle, the Heuristic Algorithm is used first until exhaustion. Once no other moves can be dine through the heuristic approach, LGSA is used. The Local Search-based Genetic Algorithm (LSGA) acts as a safety net when standard human-like rules get stuck, particularly on mathematically heavy boards. By capping the maximum number of generations, we ensure the algorithm never gets trapped in an infinite loop. This boundary guarantees that even on the hardest puzzles, the Render cloud server calculates and returns a result well within the 2-second latency limit. #footnote[*FR2: Real-time AI Processing.* When the user submits input, the backend must process it using the trained AI model immediately.]

Furthermore, the LSGA preserves the application's core educational goal through its "Hall of Fame" mechanic. Rather than simply solving the entire puzzle behind the scenes and giving away the final answer, the algorithm looks at its top near-perfect attempts (boards with 4 or fewer errors) to find a "consensus." It searches for a single empty cell where all the best boards mathematically agree on the same digit. This means the AI can confidently give the user one highly accurate, localized hint to get them unstuck, allowing them to continue learning and solving the rest of the puzzle on their own. 

The performance metrics for the combined Heuristic and LSGA approach are outlined in the table below.

#academic-table(
  columns: 5,
  caption: [Solver Performance Metrics Across All Difficulty Levels],
  table.header(
    [*Metric*], [*Easy (n=100)*], [*Medium (n=100)*], [*Hard (n=100)*], [*Evil (n=100)*],
  ),
  [Success Rate], [100.0%], [100.0%], [100.0%], [100.0%],
  [Avg Time (All) ms], [15.62], [40.13], [125.89], [321.46],
  [Avg Time (Solved) ms], [15.62], [40.13], [125.89], [321.46],
)

= User Interface and Integration

== UI Design
SudoKurious presents a clean, modern, and interactive interface. Rather than overwhelming the user with raw data, the design guides them through a seamless, educational journey. #footnote[*FR1: Intuitive User Input.* The application must allow users to provide data in a natural way for the problem being solved.]

When the user first arrives at the application, they are shown a blank landing page. From here, they can select their desired Sudoku variant and difficulty level. 

#figure(
  image("images/4bit_iso.png", width: 100%),
  caption: [The SudoKurious landing page, designed for intuitive navigation.],
)

The system supports switching between variants. Depending on the selection, the 9x9 grid instantly updates its visual language such as highlighting diagonals for X-Sudoku or rendering dotted mathematical cages for Killer Sudoku. Once a board is generated, the session timer begins.

#figure(
  grid(
    columns: (1fr, 1fr),
    gutter: 10pt,
    image("images/4bit_iso.png", width: 100%),
    image("images/4bit_iso.png", width: 100%),
  ),
  caption: [Visual distinction between the X-Sudoku (left) and Killer Sudoku (right) variants.],
)

#figure(
  image("images/4bit_iso.png", width: 80%),
  caption: [A newly generated Hard board with the active session timer running.],
)

As the user attempts to solve the puzzle, they can manually input digits into the grid. If they get stuck, they can request a hint. Instead of just printing the answer, the interface provides a floating "Alert Card" with a natural-language explanation. For simple boards, this might be a basic deduction. For complex boards, the AI provides a deep logical walkthrough, highlighting the exact row, column, or cell on the screen so the user can visually connect the logic to the board. #footnote[*FR3: Actionable Insight Display.* The AI output cannot just be a raw number (like a probability score) or raw text. It must be translated into information the user can act upon.]

#figure(
  image("images/4bit_iso.png", width: 100%),
  caption: [The UI translates algorithmic output into readable text using a simple deduction hint.],
)

#figure(
  image("images/4bit_iso.png", width: 100%),
  caption: [The hint box using a deep AI constraint explanation.],
)

Upon successfully filling the grid, the user is presented with the completed board. A modal appears asking the user to rate the AI's helpfulness during that session using a 5-star system. #footnote[*FR5: User Feedback Loop.* Users must be able to rate the accuracy of the AI output.]

#figure(
  grid(
    rows: 2,
    gutter: 10pt,
    image("images/4bit_iso.png", width: 100%),
    image("images/4bit_iso.png", width: 100%),
  ),
  caption: [Top: The 5-star feedback modal triggering upon completion. Bottom: The fully solved board state.],
)

Finally, users can open the slide-out "AI Tutor Profile." The drawer reads the user's local history to display a personalized assessment, a chronological log of their past games, and quick-reference rules on how to play each variant.

#figure(
  image("images/4bit_iso.png", width: 70%),
  caption: [The AI Tutor Profile displaying personalized assessments and session logs based on local storage history.],
)

== Integration
The application uses a simple frontend-backend architecture:
- *Frontend (User Interface):* Built using React and Next.js, the frontend is deployed on *Vercel*.
- *Backend (AI & Logic):* The machine learning pipelines (Random Forest), constraint satisfaction logic, and genetic algorithms are wrapped in a Python API and deployed on the *Render* cloud platform.

The fully integrated prototype can be accessed online at: #link("https://sudo-kurious.vercel.app")[#underline[*sudo-kurious.vercel.app*]]

= Ethical Considerations and Limitations

== Limitations
While _SudoKurious_ works well as a tutor, the current prototype has a few limitations. First, the AI expects a valid board to start with. If a user accidentally enters conflicting numbers, the main logic engine cannot proceed. We added a "Check Board" button so users can catch their mistakes before asking the AI for help. 

Additionally, boards that are completely unsolvable could technically cause the Genetic Algorithm to run endlessly. We prevented this using our "Hall of Fame" mechanic so instead of freezing, the algorithm stops after a set limit and provides the most confident hint it found. 

Finally, the app is currently restricted to three game variants, and its plain-English explanations only cover basic to intermediate strategies:
- Naked Single
- Hidden Single

For extremely advanced puzzle techniques, the system relies entirely on the algorithm to find the answer without providing a detailed text explanation.

== Ethical Considerations
_SudoKurious_ does not have a backend database. All personalized features including the AI Tutor profile, game history, and feedback ratings are saved strictly on the user's own device. #footnote[*FR4: Personalization (Context Awareness).* The system should adapt to the user over time to improve the experience.] Because the application never sends or stores personal information on external servers, the risk of data breaches is completely eliminated. Furthermore, since our AI is trained purely on the mathematical rules of Sudoku rather than human behavior, it is completely free from the human biases often found in machine learning models, ensuring it acts as an objective and fair educational tool.

= Conclusion and Future Work
In conclusion, _SudoKurious_ successfully bridges the gap between traditional brute-force solvers and educational gameplay. By acting as an interactive tutor, the application teaches users how to logically think through a puzzle rather than just handing them the final answer. To achieve this, the system relies on three AI models. First, an Advanced Random Forest model accurately predicts puzzle difficulty based on the mathematical search space. Second, a heuristic expert system provides step-by-step, natural-language hints to guide players through standard deductions. Finally, a Local Search-based Genetic Algorithm (LSGA) acts as a last resort to resolve highly complex constraints, such as those found in Killer Sudoku, ensuring the tutoring experience never stalls. 

Future iterations of the web app will focus on expanding both the technical scope and the user experience. To improve the interface, one can implement a feature that strictly locks the initial puzzle clues, preventing users from accidentally overwriting them during gameplay. Future works can also deploy a beefier testing environment to evaluate the system's performance under heavier user loads. To further personalize the AI tutor, future versions can introduce an advanced analytics mechanic that logs exactly which hints a player requests the most. By identifying which logical techniques a user struggles to discover on their own, the AI can adapt its teaching style. Finally, one can expand the application's puzzle library by integrating new game variants (such as Nonomino, Jigsaw, Windowku, and Thermo-Sudoku) while upgrading the heuristic engine to explain highly advanced human techniques (like X-Wing, Swordfish, Jellyfish, and X-Cycles).

#bibliography("references.yml", title: "9   References", full: true, style: "ieee")