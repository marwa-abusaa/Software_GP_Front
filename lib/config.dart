const url = 'http://192.168.68.100:3000/';
const registration = "${url}reg";
const login = '${url}login';
const resetPasswordAPI = '${url}forgetPass';
const sendResetLink = "${url}resetPass";
const myProfile = "${url}profile";
const newPass = "${url}newPass";
const canComment = "${url}canComment";
late String logedInEmail = "";

/// books related paths
///
const getBook = "${url}book";
const getAllBooksAPI = "${url}books";
const searchBooksAPI = "${url}bookSearch";

/////comment related paths
///
const getComments = "${url}comment";
const addComment = "${url}comment";

/// courses,contest
const newCourse = "${url}addCourse";
const getSupervisorCourses = "${url}getSupervisorCourses";
const deleteCourse = "${url}deleteCourse";
const getCourseDetailss = "${url}getCourseDetails";
const getAllCourses = "${url}getAllCourses";
const newContest = "${url}addContest";
const getSupervisorContests = "${url}getSupervisorContests";
const deleteContest = "${url}deleteContest";
const getContestDetailss = "${url}getContestDetails";
const getAllContests = "${url}getAllContests";
const updateContest = "${url}updateContest";
var TOKEN = "";
late String EMAIL = "";
var ROLE = "";

//////// create story related URLs
///
const checker = "${url}check-spelling";
const storyImage = "${url}storyImage";
const storyImageCategory = "${url}storyImageCategory";

/////my stories
const booksByStatus = "${url}myBookStatus";
const myBook = "${url}myBook";
const superReq = "${url}myBook/super";
///// contest join
///
const cnotestJoin = "${url}cnotestJoin";

const cnotestVote = "${url}cnotestVote";

const superChild = "${url}superChild";

const child = "${url}child";

//quiz
const getQuizQuestions = "${url}getQuizQuestions";
const addTotalMark = "${url}addTotalMark";
const addQuestions = "${url}addQuestion";
const checkUserQuizAttempt = "${url}checkUserQuizAttempt";
const getChildrenMark = "${url}getChildrenMark";
const getMyGrades = "${url}getMyGrades";
const getMyCourseGrade = "${url}getMyCourseGrade";
