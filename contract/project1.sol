// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }
}

/**
 * @title QuizToken
 * @dev ERC20 token implementation that rewards users for completing quizzes
 */
contract QuizToken {
    using SafeMath for uint256;
    
    // Token metadata
    string public name = "QuizToken";
    string public symbol = "QUIZ";
    uint8 public decimals = 18;
    
    // Token rewards for different quiz completion levels
    uint256 public constant EASY_QUIZ_REWARD = 5 * 10**18;    // 5 tokens
    uint256 public constant MEDIUM_QUIZ_REWARD = 10 * 10**18; // 10 tokens
    uint256 public constant HARD_QUIZ_REWARD = 20 * 10**18;   // 20 tokens
    
    // Maximum supply of tokens
    uint256 public constant MAX_SUPPLY = 1000000 * 10**18;    // 1 million tokens
    
    // Token balances and allowances
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    
    // Total supply tracker
    uint256 public totalSupply;
    
    // Contract owner
    address public owner;
    
    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    // Constructor
    constructor() {
        owner = msg.sender;
        // Mint initial supply to contract owner
        _mint(msg.sender, 100000 * 10**18);  // 100,000 tokens initially
    }
    
    // Modifier to restrict functions to owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }
    
    // Transfer ownership
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
    
    // Internal function to mint tokens
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "Mint to the zero address");
        
        totalSupply = totalSupply.add(amount);
        balanceOf[account] = balanceOf[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    
    // Function to mint tokens to the contract for rewards
    function mintRewardTokens(uint256 amount) external onlyOwner {
        require(totalSupply.add(amount) <= MAX_SUPPLY, "Exceeds maximum token supply");
        _mint(address(this), amount);
    }
    
    // Transfer tokens
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    
    // Internal function to handle transfers
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "Transfer from the zero address");
        require(recipient != address(0), "Transfer to the zero address");
        require(balanceOf[sender] >= amount, "Transfer amount exceeds balance");
        
        balanceOf[sender] = balanceOf[sender].sub(amount);
        balanceOf[recipient] = balanceOf[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    
    // Approve spender to spend tokens
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    // Internal function to handle approvals
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");
        
        allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    // Transfer from another account (requires approval)
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        
        uint256 currentAllowance = allowance[sender][msg.sender];
        require(currentAllowance >= amount, "Transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance.sub(amount));
        
        return true;
    }
}

/**
 * @title QuizApp
 * @dev Main contract for the token-backed quiz application
 */
contract QuizApp {
    using SafeMath for uint256;
    
    // Link to QuizToken
    QuizToken public quizToken;
    
    // Contract owner
    address public owner;
    
    // Quiz difficulty levels
    enum Difficulty { EASY, MEDIUM, HARD }
    
    // Quiz structure
    struct Quiz {
        uint256 id;
        string title;
        string description;
        Difficulty difficulty;
        uint256 passScore;
        uint256 questionCount;
        bool active;
        uint256 createdAt;
    }
    
    // Question structure
    struct Question {
        uint256 id;
        uint256 quizId;
        string questionText;
        string[] options;
        uint8 correctOptionIndex;
    }
    
    // User attempt structure
    struct QuizAttempt {
        uint256 id;
        address user;
        uint256 quizId;
        uint256 score;
        bool passed;
        bool rewardClaimed;
        uint256 attemptedAt;
    }
    
    // Mapping of quizzes
    mapping(uint256 => Quiz) public quizzes;
    uint256 public quizCount;
    
    // Mapping of questions
    mapping(uint256 => mapping(uint256 => Question)) public questions;
    
    // Mapping of user attempts
    mapping(address => mapping(uint256 => QuizAttempt[])) public userAttempts;
    mapping(address => uint256) public userAttemptCount;
    
    // Events
    event QuizCreated(uint256 indexed quizId, string title, Difficulty difficulty);
    event QuizAttempted(address indexed user, uint256 indexed quizId, uint256 score, bool passed);
    event RewardClaimed(address indexed user, uint256 indexed quizId, uint256 amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    // Modifier to restrict functions to owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }
    
    // Constructor
    constructor(address _tokenAddress) {
        owner = msg.sender;
        quizToken = QuizToken(_tokenAddress);
    }
    
    // Transfer ownership
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
    
    // Function to create a new quiz
    function createQuiz(
        string memory _title,
        string memory _description,
        Difficulty _difficulty,
        uint256 _passScore,
        uint256 _questionCount
    ) external onlyOwner {
        require(bytes(_title).length > 0, "Title cannot be empty");
        require(_questionCount > 0, "Quiz must have at least one question");
        require(_passScore <= _questionCount, "Pass score cannot exceed question count");
        
        quizCount++;
        
        Quiz memory newQuiz = Quiz({
            id: quizCount,
            title: _title,
            description: _description,
            difficulty: _difficulty,
            passScore: _passScore,
            questionCount: _questionCount,
            active: true,
            createdAt: block.timestamp
        });
        
        quizzes[quizCount] = newQuiz;
        
        emit QuizCreated(quizCount, _title, _difficulty);
    }
    
    // Function to add a question to a quiz
    function addQuestion(
        uint256 _quizId,
        string memory _questionText,
        string[] memory _options,
        uint8 _correctOptionIndex
    ) external onlyOwner {
        require(_quizId > 0 && _quizId <= quizCount, "Invalid quiz ID");
        require(bytes(_questionText).length > 0, "Question text cannot be empty");
        require(_options.length >= 2, "At least two options required");
        require(_correctOptionIndex < _options.length, "Correct option index out of bounds");
        
        Quiz storage quiz = quizzes[_quizId];
        
        uint256 currentQuestionCount = 0;
        for (uint256 i = 1; i <= quiz.questionCount; i++) {
            if (bytes(questions[_quizId][i].questionText).length > 0) {
                currentQuestionCount++;
            }
        }
        
        require(currentQuestionCount < quiz.questionCount, "Question limit reached for this quiz");
        
        currentQuestionCount++;
        
        Question memory newQuestion = Question({
            id: currentQuestionCount,
            quizId: _quizId,
            questionText: _questionText,
            options: _options,
            correctOptionIndex: _correctOptionIndex
        });
        
        questions[_quizId][currentQuestionCount] = newQuestion;
    }
    
    // Function to submit a quiz attempt
    function submitQuizAttempt(uint256 _quizId, uint8[] memory _answers) external {
        require(_quizId > 0 && _quizId <= quizCount, "Invalid quiz ID");
        Quiz storage quiz = quizzes[_quizId];
        require(quiz.active, "Quiz is not active");
        require(_answers.length == quiz.questionCount, "Answer count mismatch");
        
        uint256 score = 0;
        
        for (uint256 i = 0; i < _answers.length; i++) {
            if (_answers[i] == questions[_quizId][i + 1].correctOptionIndex) {
                score++;
            }
        }
        
        bool passed = score >= quiz.passScore;
        
        userAttemptCount[msg.sender]++;
        
        QuizAttempt memory newAttempt = QuizAttempt({
            id: userAttemptCount[msg.sender],
            user: msg.sender,
            quizId: _quizId,
            score: score,
            passed: passed,
            rewardClaimed: false,
            attemptedAt: block.timestamp
        });
        
        userAttempts[msg.sender][_quizId].push(newAttempt);
        
        emit QuizAttempted(msg.sender, _quizId, score, passed);
    }
    
    // Function to claim rewards for a passed quiz
    function claimReward(uint256 _quizId, uint256 _attemptId) external {
        require(_quizId > 0 && _quizId <= quizCount, "Invalid quiz ID");
        
        QuizAttempt[] storage attempts = userAttempts[msg.sender][_quizId];
        require(_attemptId > 0 && _attemptId <= attempts.length, "Invalid attempt ID");
        
        QuizAttempt storage attempt = attempts[_attemptId - 1];
        require(attempt.passed, "Quiz not passed");
        require(!attempt.rewardClaimed, "Reward already claimed");
        
        uint256 rewardAmount;
        Quiz storage quiz = quizzes[_quizId];
        
        if (quiz.difficulty == Difficulty.EASY) {
            rewardAmount = quizToken.EASY_QUIZ_REWARD();
        } else if (quiz.difficulty == Difficulty.MEDIUM) {
            rewardAmount = quizToken.MEDIUM_QUIZ_REWARD();
        } else {
            rewardAmount = quizToken.HARD_QUIZ_REWARD();
        }
        
        require(quizToken.balanceOf(address(this)) >= rewardAmount, "Insufficient reward tokens");
        
        attempt.rewardClaimed = true;
        
        bool success = quizToken.transfer(msg.sender, rewardAmount);
        require(success, "Token transfer failed");
        
        emit RewardClaimed(msg.sender, _quizId, rewardAmount);
    }
    
    // Function to get quiz details
    function getQuiz(uint256 _quizId) external view returns (Quiz memory) {
        require(_quizId > 0 && _quizId <= quizCount, "Invalid quiz ID");
        return quizzes[_quizId];
    }
    
    // Function to get quiz question
    function getQuestion(uint256 _quizId, uint256 _questionId) external view returns (
        uint256 id,
        uint256 quizId,
        string memory questionText,
        string[] memory options
    ) {
        require(_quizId > 0 && _quizId <= quizCount, "Invalid quiz ID");
        Question storage question = questions[_quizId][_questionId];
        return (question.id, question.quizId, question.questionText, question.options);
    }
    
    // Function to get user attempts for a quiz
    function getUserAttempts(uint256 _quizId) external view returns (QuizAttempt[] memory) {
        return userAttempts[msg.sender][_quizId];
    }
    
    // Function to toggle quiz active status
    function toggleQuizStatus(uint256 _quizId) external onlyOwner {
        require(_quizId > 0 && _quizId <= quizCount, "Invalid quiz ID");
        quizzes[_quizId].active = !quizzes[_quizId].active;
    }
    
    // Function to withdraw tokens from contract (emergency use)
    function withdrawTokens(uint256 _amount) external onlyOwner {
        require(_amount <= quizToken.balanceOf(address(this)), "Insufficient balance");
        bool success = quizToken.transfer(owner, _amount);
        require(success, "Token transfer failed");
    }
    
    // Function to receive ETH (if needed)
    receive() external payable {}
    
    // Function to withdraw ETH from contract (if needed)
    function withdrawETH() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
