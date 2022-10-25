// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./certificate.sol";

contract School is Ownable {
    //important
    //owner of all contract should be same otherwise certifications wont work

    uint16 public tax = 3; //default tax
    status public statusDefault = status.NOT_ENROLLED; //default student status
    uint256 baseTerm = 0;
    uint256 sharingTerm = 0;
    Certificate public certificateContract; //pointer to nft contract

    struct Course {
        string name;
        address assignedTeacher;
        uint256 basePrice; //teacher's price
        uint256 sharePrice;
        uint256 price;
        mapping (address => status) students;
    }

    mapping (address => bool) isTeacher;
    Course[] courses; //stores all the courses

    modifier onlyTeacher() {
        require (isTeacher[msg.sender] == true, "not authorized to create course");
        _;
    }

    enum status {NOT_ENROLLED, ENROLLED, COMPLETED}

    event newCourse (string indexed name, uint indexed index);

    constructor(Certificate _certificateContract) {
        certificateContract = _certificateContract;
    }

    //functions for owner

    //add a new teacher
    function addTeacher(address _teacher) public onlyOwner {
        isTeacher[_teacher] = true;
    }

    function setTax(uint16 _tax) public onlyOwner {
        tax = _tax;
    }

    function setBaseTerm(uint16 _baseTerm) public onlyOwner {
        baseTerm = _baseTerm;
    }

    //functions for teacher

    //create course
    function createCourse(string memory _courseName, address _teacher, uint _base) public onlyTeacher {
        Course storage c = courses.push();
        c.name = _courseName;
        c.assignedTeacher = _teacher;
        c.basePrice = _base;
        c.sharePrice = calculateSharePrice(c);
        c.price = calculatePrice(c);
        emit newCourse(_courseName, courses.length-1);
    }

    function setShareTerm(uint16 _sharingTerm) public onlyTeacher {
        require(_sharingTerm > baseTerm);
        sharingTerm = _sharingTerm;
    }

    //once a student completes the course the teacher van graduate him
    //once the stutus is complete an nft is transfered to him
    function graduate(uint _courseIndex, address _student) public onlyTeacher onlyOwner {
        require(courses[_courseIndex].students[_student] == status.ENROLLED, "student not enrolled");
        courses[_courseIndex].students[_student] = status.COMPLETED;
        certificateContract.mint(_student);
    }

    //private functions

    function calculatePrice(Course storage _course) private view returns (uint) {
        return (_course.basePrice * _course.sharePrice * (tax/100));
    }

    //calculate share price
    //if sharing term is not present se base term instead
    function calculateSharePrice(Course storage _course) private view returns (uint) {
        require (sharingTerm != 0 && baseTerm!=0);
        uint256 st = 0;
        if (sharingTerm != 0) {
            st = sharingTerm;
        } else {
            st = baseTerm;
        }
        return (_course.basePrice * (st / 100));
    }

    //when a student pays fee this function divides the fee between entities
    function divideFee(Course storage _course) private {
        (bool success, ) = owner().call{value: _course.price * (baseTerm / 100 )}('');
        require(success);
        (bool success1, ) = _course.assignedTeacher.call{value: _course.price * (sharingTerm / 100 )}('');
        require(success1);
    }

    //functions for students

    function enroll(uint _courseIndex) public payable {
        require(msg.sender == address(0));
        require(msg.value == courses[_courseIndex].price);
        Course storage c = courses[_courseIndex];
        c.students[msg.sender] = status.ENROLLED;
        divideFee(c);
    }

    function viewPrice(uint _courseIndex) public view returns(uint) {
        return courses[_courseIndex].price;
    }
}
