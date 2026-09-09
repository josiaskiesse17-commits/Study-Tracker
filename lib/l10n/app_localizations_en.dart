// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get login => 'Login';

  @override
  String get welcomeBack => 'Welcome back to StudyTrack';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get createAccount => 'Create an account';

  @override
  String get createStudyTrackAccount => 'Create your StudyTrack account';

  @override
  String get register => 'Register';

  @override
  String get fullName => 'Full name';

  @override
  String get alreadyHaveAccount => 'Already have an account? Login';

  @override
  String get enterFullName => 'Enter your full name';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get enterValidEmail => 'Enter a valid email';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get courses => 'Courses';

  @override
  String get work => 'Work';

  @override
  String get projects => 'Projects';

  @override
  String get profile => 'Profile';

  @override
  String get projectDetails => 'Project Details';

  @override
  String get projectContent => 'Project content';

  @override
  String get milestones => 'Milestones';

  @override
  String get coursesAssociated => 'Courses associated with this project';

  @override
  String get workAssociated => 'Work associated with this project';

  @override
  String get noDeadline => 'No deadline';

  @override
  String get there => 'there';

  @override
  String welcomeUser(Object name) {
    return 'Welcome, $name!';
  }

  @override
  String get switchToLightMode => 'Switch to light mode';

  @override
  String get switchToDarkMode => 'Switch to dark mode';

  @override
  String get logout => 'Logout';

  @override
  String get keepLearningMessage => 'Keep learning, stay organized, and make progress every day.';

  @override
  String get yourWorkspace => 'Your workspace';

  @override
  String get manageLearningMessage => 'Manage your learning from one place.';

  @override
  String get trackCourseProgress => 'Track your course progress';

  @override
  String get organizeAccomplish => 'Organize what you need to accomplish';

  @override
  String get manageLargerProjects => 'Manage your larger projects';

  @override
  String get stayConsistent => 'Stay consistent';

  @override
  String get stayConsistentMessage => 'Break your learning goals into small tasks and keep your courses up to date.';

  @override
  String get myCourses => 'My Courses';

  @override
  String get createCourse => 'Create course';

  @override
  String get unableToLoadCourses => 'Unable to load courses.';

  @override
  String get noCoursesYet => 'No courses yet';

  @override
  String get createFirstCourse => 'Create your first course and start tracking your progress.';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get progress => 'Progress';

  @override
  String get deleteCourse => 'Delete course?';

  @override
  String deleteCourseConfirmation(Object courseName) {
    return 'Are you sure you want to delete \"$courseName\"?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String failedToDeleteCourse(Object error) {
    return 'Failed to delete course: $error';
  }

  @override
  String get editCourse => 'Edit course';

  @override
  String get courseName => 'Course name';

  @override
  String get description => 'Description';

  @override
  String get optional => 'Optional';

  @override
  String get courseNameRequired => 'Course name is required.';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get create => 'Create';

  @override
  String failedToSaveCourse(Object error) {
    return 'Failed to save course: $error';
  }

  @override
  String get tryAgain => 'Try again';

  @override
  String get createWorkItem => 'Create work item';

  @override
  String get noWorkYet => 'No work yet';

  @override
  String get addWorkDescription => 'Add homework, assignments, readings, exams, exercises and other things you need to accomplish.';

  @override
  String get addWork => 'Add work';

  @override
  String get workActions => 'Work actions';

  @override
  String get deleteWork => 'Delete work?';

  @override
  String deleteWorkConfirmation(Object title) {
    return 'Are you sure you want to delete \"$title\"?';
  }

  @override
  String get editWork => 'Edit work';

  @override
  String get createWork => 'Create work';

  @override
  String get title => 'Title';

  @override
  String get type => 'Type';

  @override
  String get status => 'Status';

  @override
  String get priority => 'Priority';

  @override
  String get dueDate => 'Due date';

  @override
  String get tapToChange => 'Tap to change';

  @override
  String get removeDueDate => 'Remove due date';

  @override
  String get titleRequired => 'Title is required.';

  @override
  String failedToSaveWork(Object error) {
    return 'Failed to save work: $error';
  }

  @override
  String get homework => 'Homework';

  @override
  String get assignment => 'Assignment';

  @override
  String get reading => 'Reading';

  @override
  String get exercise => 'Exercise';

  @override
  String get exam => 'Exam';

  @override
  String get quiz => 'Quiz';

  @override
  String get practice => 'Practice';

  @override
  String get other => 'Other';

  @override
  String get pending => 'Pending';

  @override
  String get inProgress => 'In progress';

  @override
  String get completed => 'Completed';

  @override
  String get highPriority => 'High priority';

  @override
  String get mediumPriority => 'Medium priority';

  @override
  String get lowPriority => 'Low priority';

  @override
  String get unableToLoadWork => 'Unable to load work';

  @override
  String get unableToLoadProjects => 'Unable to load projects.';

  @override
  String get retry => 'Retry';

  @override
  String get addProject => 'Add project';

  @override
  String get createProject => 'Create project';

  @override
  String get editProject => 'Edit project';

  @override
  String get name => 'Name';

  @override
  String get projectName => 'Project name';

  @override
  String get optionalDescription => 'Optional description';

  @override
  String get planning => 'Planning';

  @override
  String get clearDeadline => 'Clear deadline';

  @override
  String get projectNameRequired => 'Project name is required.';

  @override
  String get save => 'Save';

  @override
  String get deleteProject => 'Delete project?';

  @override
  String permanentlyDeleteProject(Object projectName) {
    return 'This will permanently delete \"$projectName\".';
  }

  @override
  String get noProjectsYet => 'No projects yet';

  @override
  String get createProjectDescription => 'Create a project to organize a larger piece of work.';

  @override
  String get projectActions => 'Project actions';
}
