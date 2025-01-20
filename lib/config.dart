const url = 'http://192.168.68.109:3000/';
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

//recordes
const addRecorde = "${url}recordings";
const getRecords = "${url}getRecordings";

//winner
const getWinnersss = "${url}getWinners";
const getWinnersBySupervisor = "${url}getWinnersBySupervisor";

//search user
const searchChildren = "${url}users/search";

// fav
const fav = "${url}users/favorites";

// follow
const follow = "${url}follow";
const unfollow = "${url}unfollow";
const list = "${url}list";
const following = "${url}is-following";
const followingBooks = "${url}following-books";
const followingSearch = "${url}searchFollow";
const all_children = "${url}all-children";

const progress = "${url}progress";
const notActive = "${url}notActive";
const activate = "${url}activate";

//marwa
const all_users = "${url}all-supervisors";

//aya
const searchActive = "${url}search-notActive";
const categories = "${url}categories";
const progressAdmin = "${url}admin/progress";
const gender_statistics = "${url}gender-statistics";
const age_statistics = "${url}age-statistics";
