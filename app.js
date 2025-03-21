let web3;
let contract;
const contractAddress = "0x5E7B73e43d3cA464E7acFcc6F02AA831F7D7481a";
const contractABI = [
    [
        {
            "inputs": [
                {
                    "internalType": "address",
                    "name": "_tokenAddress",
                    "type": "address"
                }
            ],
            "stateMutability": "nonpayable",
            "type": "constructor"
        },
        {
            "anonymous": false,
            "inputs": [
                {
                    "indexed": true,
                    "internalType": "address",
                    "name": "previousOwner",
                    "type": "address"
                },
                {
                    "indexed": true,
                    "internalType": "address",
                    "name": "newOwner",
                    "type": "address"
                }
            ],
            "name": "OwnershipTransferred",
            "type": "event"
        },
        {
            "anonymous": false,
            "inputs": [
                {
                    "indexed": true,
                    "internalType": "address",
                    "name": "user",
                    "type": "address"
                },
                {
                    "indexed": true,
                    "internalType": "uint256",
                    "name": "quizId",
                    "type": "uint256"
                },
                {
                    "indexed": false,
                    "internalType": "uint256",
                    "name": "score",
                    "type": "uint256"
                },
                {
                    "indexed": false,
                    "internalType": "bool",
                    "name": "passed",
                    "type": "bool"
                }
            ],
            "name": "QuizAttempted",
            "type": "event"
        },
        {
            "anonymous": false,
            "inputs": [
                {
                    "indexed": true,
                    "internalType": "uint256",
                    "name": "quizId",
                    "type": "uint256"
                },
                {
                    "indexed": false,
                    "internalType": "string",
                    "name": "title",
                    "type": "string"
                },
                {
                    "indexed": false,
                    "internalType": "enum QuizApp.Difficulty",
                    "name": "difficulty",
                    "type": "uint8"
                }
            ],
            "name": "QuizCreated",
            "type": "event"
        },
        {
            "anonymous": false,
            "inputs": [
                {
                    "indexed": true,
                    "internalType": "address",
                    "name": "user",
                    "type": "address"
                },
                {
                    "indexed": true,
                    "internalType": "uint256",
                    "name": "quizId",
                    "type": "uint256"
                },
                {
                    "indexed": false,
                    "internalType": "uint256",
                    "name": "amount",
                    "type": "uint256"
                }
            ],
            "name": "RewardClaimed",
            "type": "event"
        },
        {
            "inputs": [
                {
                    "internalType": "uint256",
                    "name": "_quizId",
                    "type": "uint256"
                },
                {
                    "internalType": "string",
                    "name": "_questionText",
                    "type": "string"
                },
                {
                    "internalType": "string[]",
                    "name": "_options",
                    "type": "string[]"
                },
                {
                    "internalType": "uint8",
                    "name": "_correctOptionIndex",
                    "type": "uint8"
                }
            ],
            "name": "addQuestion",
            "outputs": [],
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "uint256",
                    "name": "_quizId",
                    "type": "uint256"
                },
                {
                    "internalType": "uint256",
                    "name": "_attemptId",
                    "type": "uint256"
                }
            ],
            "name": "claimReward",
            "outputs": [],
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "string",
                    "name": "_title",
                    "type": "string"
                },
                {
                    "internalType": "string",
                    "name": "_description",
                    "type": "string"
                },
                {
                    "internalType": "enum QuizApp.Difficulty",
                    "name": "_difficulty",
                    "type": "uint8"
                },
                {
                    "internalType": "uint256",
                    "name": "_passScore",
                    "type": "uint256"
                },
                {
                    "internalType": "uint256",
                    "name": "_questionCount",
                    "type": "uint256"
                }
            ],
            "name": "createQuiz",
            "outputs": [],
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "uint256",
                    "name": "_quizId",
                    "type": "uint256"
                },
                {
                    "internalType": "uint256",
                    "name": "_questionId",
                    "type": "uint256"
                }
            ],
            "name": "getQuestion",
            "outputs": [
                {
                    "internalType": "uint256",
                    "name": "id",
                    "type": "uint256"
                },
                {
                    "internalType": "uint256",
                    "name": "quizId",
                    "type": "uint256"
                },
                {
                    "internalType": "string",
                    "name": "questionText",
                    "type": "string"
                },
                {
                    "internalType": "string[]",
                    "name": "options",
                    "type": "string[]"
                }
            ],
            "stateMutability": "view",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "uint256",
                    "name": "_quizId",
                    "type": "uint256"
                }
            ],
            "name": "getQuiz",
            "outputs": [
                {
                    "components": [
                        {
                            "internalType": "uint256",
                            "name": "id",
                            "type": "uint256"
                        },
                        {
                            "internalType": "string",
                            "name": "title",
                            "type": "string"
                        },
                        {
                            "internalType": "string",
                            "name": "description",
                            "type": "string"
                        },
                        {
                            "internalType": "enum QuizApp.Difficulty",
                            "name": "difficulty",
                            "type": "uint8"
                        },
                        {
                            "internalType": "uint256",
                            "name": "passScore",
                            "type": "uint256"
                        },
                        {
                            "internalType": "uint256",
                            "name": "questionCount",
                            "type": "uint256"
                        },
                        {
                            "internalType": "bool",
                            "name": "active",
                            "type": "bool"
                        },
                        {
                            "internalType": "uint256",
                            "name": "createdAt",
                            "type": "uint256"
                        }
                    ],
                    "internalType": "struct QuizApp.Quiz",
                    "name": "",
                    "type": "tuple"
                }
            ],
            "stateMutability": "view",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "uint256",
                    "name": "_quizId",
                    "type": "uint256"
                }
            ],
            "name": "getUserAttempts",
            "outputs": [
                {
                    "components": [
                        {
                            "internalType": "uint256",
                            "name": "id",
                            "type": "uint256"
                        },
                        {
                            "internalType": "address",
                            "name": "user",
                            "type": "address"
                        },
                        {
                            "internalType": "uint256",
                            "name": "quizId",
                            "type": "uint256"
                        },
                        {
                            "internalType": "uint256",
                            "name": "score",
                            "type": "uint256"
                        },
                        {
                            "internalType": "bool",
                            "name": "passed",
                            "type": "bool"
                        },
                        {
                            "internalType": "bool",
                            "name": "rewardClaimed",
                            "type": "bool"
                        },
                        {
                            "internalType": "uint256",
                            "name": "attemptedAt",
                            "type": "uint256"
                        }
                    ],
                    "internalType": "struct QuizApp.QuizAttempt[]",
                    "name": "",
                    "type": "tuple[]"
                }
            ],
            "stateMutability": "view",
            "type": "function"
        },
        {
            "inputs": [],
            "name": "owner",
            "outputs": [
                {
                    "internalType": "address",
                    "name": "",
                    "type": "address"
                }
            ],
            "stateMutability": "view",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "uint256",
                    "name": "",
                    "type": "uint256"
                },
                {
                    "internalType": "uint256",
                    "name": "",
                    "type": "uint256"
                }
            ],
            "name": "questions",
            "outputs": [
                {
                    "internalType": "uint256",
                    "name": "id",
                    "type": "uint256"
                },
                {
                    "internalType": "uint256",
                    "name": "quizId",
                    "type": "uint256"
                },
                {
                    "internalType": "string",
                    "name": "questionText",
                    "type": "string"
                },
                {
                    "internalType": "uint8",
                    "name": "correctOptionIndex",
                    "type": "uint8"
                }
            ],
            "stateMutability": "view",
            "type": "function"
        },
        {
            "inputs": [],
            "name": "quizCount",
            "outputs": [
                {
                    "internalType": "uint256",
                    "name": "",
                    "type": "uint256"
                }
            ],
            "stateMutability": "view",
            "type": "function"
        },
        {
            "inputs": [],
            "name": "quizToken",
            "outputs": [
                {
                    "internalType": "contract QuizToken",
                    "name": "",
                    "type": "address"
                }
            ],
            "stateMutability": "view",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "uint256",
                    "name": "",
                    "type": "uint256"
                }
            ],
            "name": "quizzes",
            "outputs": [
                {
                    "internalType": "uint256",
                    "name": "id",
                    "type": "uint256"
                },
                {
                    "internalType": "string",
                    "name": "title",
                    "type": "string"
                },
                {
                    "internalType": "string",
                    "name": "description",
                    "type": "string"
                },
                {
                    "internalType": "enum QuizApp.Difficulty",
                    "name": "difficulty",
                    "type": "uint8"
                },
                {
                    "internalType": "uint256",
                    "name": "passScore",
                    "type": "uint256"
                },
                {
                    "internalType": "uint256",
                    "name": "questionCount",
                    "type": "uint256"
                },
                {
                    "internalType": "bool",
                    "name": "active",
                    "type": "bool"
                },
                {
                    "internalType": "uint256",
                    "name": "createdAt",
                    "type": "uint256"
                }
            ],
            "stateMutability": "view",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "uint256",
                    "name": "_quizId",
                    "type": "uint256"
                },
                {
                    "internalType": "uint8[]",
                    "name": "_answers",
                    "type": "uint8[]"
                }
            ],
            "name": "submitQuizAttempt",
            "outputs": [],
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "uint256",
                    "name": "_quizId",
                    "type": "uint256"
                }
            ],
            "name": "toggleQuizStatus",
            "outputs": [],
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "address",
                    "name": "newOwner",
                    "type": "address"
                }
            ],
            "name": "transferOwnership",
            "outputs": [],
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "address",
                    "name": "",
                    "type": "address"
                }
            ],
            "name": "userAttemptCount",
            "outputs": [
                {
                    "internalType": "uint256",
                    "name": "",
                    "type": "uint256"
                }
            ],
            "stateMutability": "view",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "address",
                    "name": "",
                    "type": "address"
                },
                {
                    "internalType": "uint256",
                    "name": "",
                    "type": "uint256"
                },
                {
                    "internalType": "uint256",
                    "name": "",
                    "type": "uint256"
                }
            ],
            "name": "userAttempts",
            "outputs": [
                {
                    "internalType": "uint256",
                    "name": "id",
                    "type": "uint256"
                },
                {
                    "internalType": "address",
                    "name": "user",
                    "type": "address"
                },
                {
                    "internalType": "uint256",
                    "name": "quizId",
                    "type": "uint256"
                },
                {
                    "internalType": "uint256",
                    "name": "score",
                    "type": "uint256"
                },
                {
                    "internalType": "bool",
                    "name": "passed",
                    "type": "bool"
                },
                {
                    "internalType": "bool",
                    "name": "rewardClaimed",
                    "type": "bool"
                },
                {
                    "internalType": "uint256",
                    "name": "attemptedAt",
                    "type": "uint256"
                }
            ],
            "stateMutability": "view",
            "type": "function"
        },
        {
            "inputs": [],
            "name": "withdrawETH",
            "outputs": [],
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "uint256",
                    "name": "_amount",
                    "type": "uint256"
                }
            ],
            "name": "withdrawTokens",
            "outputs": [],
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "stateMutability": "payable",
            "type": "receive"
        }
    ]
];

document.getElementById("connectWallet").addEventListener("click", async () => {
    if (window.ethereum) {
        web3 = new Web3(window.ethereum);
        await window.ethereum.request({ method: "eth_requestAccounts" });
        contract = new web3.eth.Contract(contractABI, contractAddress);
        document.getElementById("quizContainer").classList.remove("hidden");
        loadQuizzes();
    } else {
        alert("Please install MetaMask");
    }
});

async function loadQuizzes() {
    // Fetch quiz data from the contract (to be implemented)
    console.log("Fetching quizzes...");
}
