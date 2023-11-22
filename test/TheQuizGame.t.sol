// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console2} from "forge-std/Test.sol";
import {TheQuizGame} from "../src/TheQuizGame.sol";

contract TheQuizGameTest is Test {
    TheQuizGame public theQuizGame;

    function setUp() public {
        theQuizGame = new TheQuizGame();
    }

    function testDeployContract() public {
        assertEq(
            address(theQuizGame),
            0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f
        );
        assertEq(theQuizGame.quizId(), 0);
    }

    function testQuizIdVariable() public {
        assertEq(theQuizGame.quizId(), 0);
    }

    function testCreateQuiz() public {
        string
            memory _question = "what programming language is used to create smart contracts on Ethereum";
        string memory _answer = "solidity";
        uint256 quizId = 1;
        bytes32 hashedAnswer = keccak256(
            abi.encodePacked(bytes32(quizId), _answer)
        );
        theQuizGame.createQuiz(_question, _answer);

        (
            address addr,
            string memory question,
            bytes32 answer,
            bool isAnswered
        ) = theQuizGame.quiz(1);

        assertEq(theQuizGame.quizId(), 1);
        assertEq(addr, address(this));
        assertEq(question, _question);
        assertEq(answer, hashedAnswer);
        assertEq(isAnswered, false);
    }

    function testAnswerQuiz() public {
        string
            memory _question = "what programming language is used to create smart contracts on Ethereum";
        string memory _answer = "solidity";
        uint256 quizId = 1;
        theQuizGame.createQuiz(_question, _answer);

        vm.startPrank(address(0x1));
        theQuizGame.answerQuiz(quizId, _answer);
        (address assigner, , , bool isAnswered) = theQuizGame.quiz(1);

        assertEq(assigner, address(this));
        assertEq(theQuizGame.score(address(0x1)), 1);
        assertEq(isAnswered, true);
    }

    function testErrorAssignerNotAllowed() public {
        string
            memory _question = "what programming language is used to create smart contracts on Ethereum";
        string memory _answer = "solidity";
        uint256 quizId = 1;
        theQuizGame.createQuiz(_question, _answer);

        vm.expectRevert(TheQuizGame.AssignerNotAllowed.selector);
        theQuizGame.answerQuiz(quizId, _answer);
    }

    function testErrorQuizHasBeenAnswered() public {
        string
            memory _question = "what programming language is used to create smart contracts on Ethereum";
        string memory _answer = "solidity";
        uint256 quizId = 1;
        theQuizGame.createQuiz(_question, _answer);

        vm.startPrank(address(0x2));
        theQuizGame.answerQuiz(quizId, _answer);

        vm.expectRevert(TheQuizGame.QuizHasBeenAnswered.selector);
        theQuizGame.answerQuiz(quizId, _answer);
    }

    function testErrorWrongUnswer() public {
        string
            memory _question = "what programming language is used to create smart contracts on Ethereum";
        string memory _answer = "solidity";
        uint256 quizId = 1;
        theQuizGame.createQuiz(_question, _answer);

        vm.startPrank(address(0x2));
        vm.expectRevert(TheQuizGame.WrongUnswer.selector);
        theQuizGame.answerQuiz(quizId, "Solidity");
    }
}
