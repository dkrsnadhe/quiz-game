// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/* 
    @title QuizGame 
    @author dkrsnadhe
*/

contract TheQuizGame {
    /*
        @title quizId
        @notice The ID for Quiz
        @dev Used to provide an ID to the Quiz 
        @return The ID of Quiz
    */
    uint256 public quizId;

    /*
        @title CreateQuiz
        @notice Event emitted upon the creation of a new quiz
        @dev This event logs the details of a newly created quiz
        @param _quizId The unique identifier of the quiz
        @param _time The timestamp representing the creation time of the quiz
        @param _assigner The address of the entity assigning or creating the quiz
        @param _question The question for the quiz
        @param _hashedAnswer The hashed answer for the quiz
    */
    event CreateQuiz(
        uint256 _quizId,
        uint256 _time,
        address indexed _assigner,
        string _question,
        bytes32 _hashedAnswer
    );

    /*
        @title AnswerQuiz
        @notice Event emitted upon answering a quiz
        @dev This event logs the details when a quiz is answered
        @param _quizId The unique identifier of the quiz
        @param _time The timestamp representing the creation time of the quiz
        @param _assigneeScore The score achieved by the assignee for the quiz
        @param _assignee The address of the entity answering the quiz
        @param _isAnswered A boolean indicating whether the quiz is answered or not
    */
    event AnswerQuiz(
        uint256 _quizId,
        uint256 _time,
        uint256 _assigneeScore,
        address indexed _assignee,
        bytes32 _hashedAnswer,
        bool _isAnswered
    );

    /*
        @notice Constructor function to initialize the quiz ID
        @dev Invoked when deploying the contract and sets the initial value of the quizId to 0
    */
    constructor() {
        quizId = 0;
    }

    /*
        @title Quiz
        @notice Defining the properties of a quiz
        @dev This struct defines the characteristics of a quiz including 
            assigner of quiz, quiz question, hashedAnswer representing the quiz answer, 
            and isAnswered representing the quiz is answered or not
    */
    struct Quiz {
        address assigner;
        string question;
        bytes32 hashedAnswer;
        bool isAnswered;
    }

    /*
        @title quiz
        @notice Mapping to store quiz details based on their IDs
    */
    mapping(uint256 => Quiz) public quiz;

    /*
        @title score
        @notice Mapping to store scores associated with addresses
    */
    mapping(address => uint256) public score;

    error AssignerNotAllowed();
    error QuizHasBeenAnswered();
    error WrongUnswer();

    /*
        @title createQuiz
        @notice Function to create a new quiz
        @dev This function allows the creation of a new quiz with a question and answer provided by the caller.
            The caller will be a assigner of the quiz, the answer will be hashed. The `CreateQuiz` event is emitted to log the creation of the quiz
        @param _question The question for the new quiz
        @param _answer The answer for the new quiz 
    */
    function createQuiz(
        string calldata _question,
        string calldata _answer
    ) external {
        quizId++;
        quiz[quizId] = Quiz(
            msg.sender,
            _question,
            keccak256(abi.encodePacked(bytes32(quizId), _answer)),
            false
        );

        emit CreateQuiz(
            quizId,
            block.timestamp,
            msg.sender,
            _question,
            keccak256(abi.encodePacked(quizId, _answer))
        );
    }

    /*
        @title answerQuiz
        @notice Function to answer a specific quiz
        @dev This function allows a user to answer a quiz by providing the quiz ID and the answer.
            It verifies the correctness of the provided answer against the hashed answer stored in the quiz.
            If the answer is correct, it marks the quiz as answered, increments the user's score, and emits the `AnswerQuiz` event
        @param _quizId The ID of the quiz being answered
        @param _answer The answer provided by the user for the quiz
    */
    function answerQuiz(uint256 _quizId, string calldata _answer) external {
        if (msg.sender == quiz[_quizId].assigner) {
            revert AssignerNotAllowed();
        }

        if (quiz[_quizId].isAnswered) {
            revert QuizHasBeenAnswered();
        }

        if (
            keccak256(abi.encodePacked(bytes32(_quizId), _answer)) !=
            quiz[_quizId].hashedAnswer
        ) {
            revert WrongUnswer();
        }

        quiz[_quizId].isAnswered = true;
        score[msg.sender]++;

        emit AnswerQuiz(
            _quizId,
            block.timestamp,
            score[msg.sender],
            msg.sender,
            keccak256(abi.encodePacked(bytes32(_quizId), _answer)),
            true
        );
    }
}
