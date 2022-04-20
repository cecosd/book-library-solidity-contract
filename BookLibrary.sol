// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract BookLibrary {
    
    mapping (address => uint[]) public borrowedBooksToUsers;
    mapping (uint => address[]) public borrowedBooksHistory;
    mapping (uint => uint) public availableBooks;
    mapping (address => uint[]) public bufferUserBooks;

    uint latestBookId = 1;
    
    struct Book {
        string bookTitle;
        uint copies;
    }

    Book[] public books;
    
    function addBook(string memory _bookTitle, uint _copies) public {
        books.push(Book(_bookTitle, _copies));
        uint id = books.length - 1;
        availableBooks[id] = _copies;
    }

    function borrowBook(uint bookId) public {
        uint bookCopies = availableBooks[bookId];
        require(bookCopies > 0, "The book is currently unavailable");
        availableBooks[bookId] = availableBooks[bookId] - 1;
        borrowedBooksToUsers[msg.sender].push(bookId);

        bool addToHistory = true;
        for (uint i = 0; i<borrowedBooksHistory[bookId].length; i++){
            if(borrowedBooksHistory[bookId][i] == msg.sender) {
                addToHistory = false;
            }
        }
        
        if(addToHistory) {
            borrowedBooksHistory[bookId].push(msg.sender);
        }
    }

    function returnBook(uint bookId) public {
        uint bookCopies = availableBooks[bookId];
        require(bookCopies < books[bookId].copies, "All the copies were already returned");
        availableBooks[bookId] = availableBooks[bookId] + 1;
        for (uint i = 0; i<borrowedBooksToUsers[msg.sender].length; i++){
            if(borrowedBooksToUsers[msg.sender][i] != bookId) {
                bufferUserBooks[msg.sender].push(borrowedBooksToUsers[msg.sender][i]);
            }
        }
        borrowedBooksToUsers[msg.sender] = new uint[](0);
        borrowedBooksToUsers[msg.sender] = bufferUserBooks[msg.sender];
        bufferUserBooks[msg.sender] = new uint[](0);
    }

    function getAvailableBookCopies(uint bookId) public view returns(uint) {
        return availableBooks[bookId];
    }

    function getUserBooks(address user) public view returns(uint[] memory) {
        return borrowedBooksToUsers[user];
    }

    function getBookBorrowingHistory(uint bookId) public view returns(address[] memory) {
        return borrowedBooksHistory[bookId];
    }

    function _userHasCopies(address user, uint bookId) internal view returns(uint) {
        return borrowedBooksToUsers[user][bookId];
    }
}
