// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get login => 'Connexion';

  @override
  String get welcomeBack => 'Bon retour sur StudyTrack';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get createStudyTrackAccount => 'Créez votre compte StudyTrack';

  @override
  String get register => 'S\'inscrire';

  @override
  String get fullName => 'Nom complet';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte ? Connexion';

  @override
  String get enterFullName => 'Entrez votre nom complet';

  @override
  String get enterEmail => 'Entrez votre e-mail';

  @override
  String get enterValidEmail => 'Entrez un e-mail valide';

  @override
  String get enterPassword => 'Entrez votre mot de passe';

  @override
  String get passwordMinLength => 'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get courses => 'Cours';

  @override
  String get work => 'Travail';

  @override
  String get projects => 'Projets';

  @override
  String get profile => 'Profil';

  @override
  String get projectDetails => 'Détails du projet';

  @override
  String get projectContent => 'Contenu du projet';

  @override
  String get milestones => 'Jalons';

  @override
  String get coursesAssociated => 'Cours associés à ce projet';

  @override
  String get workAssociated => 'Travail associé à ce projet';

  @override
  String get noDeadline => 'Aucune échéance';

  @override
  String get there => 'vous';

  @override
  String welcomeUser(Object name) {
    return 'Bienvenue, $name !';
  }

  @override
  String get switchToLightMode => 'Passer au mode clair';

  @override
  String get switchToDarkMode => 'Passer au mode sombre';

  @override
  String get logout => 'Déconnexion';

  @override
  String get keepLearningMessage => 'Continuez à apprendre, restez organisé et progressez chaque jour.';

  @override
  String get yourWorkspace => 'Votre espace de travail';

  @override
  String get manageLearningMessage => 'Gérez votre apprentissage depuis un seul endroit.';

  @override
  String get trackCourseProgress => 'Suivez la progression de vos cours';

  @override
  String get organizeAccomplish => 'Organisez ce que vous devez accomplir';

  @override
  String get manageLargerProjects => 'Gérez vos projets plus importants';

  @override
  String get stayConsistent => 'Restez constant';

  @override
  String get stayConsistentMessage => 'Découpez vos objectifs d\'apprentissage en petites tâches et maintenez vos cours à jour.';

  @override
  String get myCourses => 'Mes cours';

  @override
  String get createCourse => 'Créer un cours';

  @override
  String get unableToLoadCourses => 'Impossible de charger les cours.';

  @override
  String get noCoursesYet => 'Aucun cours pour le moment';

  @override
  String get createFirstCourse => 'Créez votre premier cours et commencez à suivre votre progression.';

  @override
  String get edit => 'Modifier';

  @override
  String get delete => 'Supprimer';

  @override
  String get progress => 'Progression';

  @override
  String get deleteCourse => 'Supprimer le cours ?';

  @override
  String deleteCourseConfirmation(Object courseName) {
    return 'Voulez-vous vraiment supprimer « $courseName » ?';
  }

  @override
  String get cancel => 'Annuler';

  @override
  String failedToDeleteCourse(Object error) {
    return 'Échec de la suppression du cours : $error';
  }

  @override
  String get editCourse => 'Modifier le cours';

  @override
  String get courseName => 'Nom du cours';

  @override
  String get description => 'Description';

  @override
  String get optional => 'Facultatif';

  @override
  String get courseNameRequired => 'Le nom du cours est obligatoire.';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get create => 'Créer';

  @override
  String failedToSaveCourse(Object error) {
    return 'Échec de l\'enregistrement du cours : $error';
  }

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get createWorkItem => 'Créer un élément de travail';

  @override
  String get noWorkYet => 'Aucun travail pour le moment';

  @override
  String get addWorkDescription => 'Ajoutez des devoirs, travaux, lectures, examens, exercices et autres tâches à accomplir.';

  @override
  String get addWork => 'Ajouter un travail';

  @override
  String get workActions => 'Actions du travail';

  @override
  String get deleteWork => 'Supprimer le travail ?';

  @override
  String deleteWorkConfirmation(Object title) {
    return 'Voulez-vous vraiment supprimer « $title » ?';
  }

  @override
  String get editWork => 'Modifier le travail';

  @override
  String get createWork => 'Créer un travail';

  @override
  String get title => 'Titre';

  @override
  String get type => 'Type';

  @override
  String get status => 'Statut';

  @override
  String get priority => 'Priorité';

  @override
  String get dueDate => 'Date d\'échéance';

  @override
  String get tapToChange => 'Appuyez pour modifier';

  @override
  String get removeDueDate => 'Supprimer la date d\'échéance';

  @override
  String get titleRequired => 'Le titre est obligatoire.';

  @override
  String failedToSaveWork(Object error) {
    return 'Échec de l\'enregistrement du travail : $error';
  }

  @override
  String get homework => 'Devoir';

  @override
  String get assignment => 'Travail';

  @override
  String get reading => 'Lecture';

  @override
  String get exercise => 'Exercice';

  @override
  String get exam => 'Examen';

  @override
  String get quiz => 'Quiz';

  @override
  String get practice => 'Pratique';

  @override
  String get other => 'Autre';

  @override
  String get pending => 'En attente';

  @override
  String get inProgress => 'En cours';

  @override
  String get completed => 'Terminé';

  @override
  String get highPriority => 'Priorité élevée';

  @override
  String get mediumPriority => 'Priorité moyenne';

  @override
  String get lowPriority => 'Priorité faible';

  @override
  String get unableToLoadWork => 'Impossible de charger le travail';

  @override
  String get unableToLoadProjects => 'Impossible de charger les projets.';

  @override
  String get retry => 'Réessayer';

  @override
  String get addProject => 'Ajouter un projet';

  @override
  String get createProject => 'Créer un projet';

  @override
  String get editProject => 'Modifier le projet';

  @override
  String get name => 'Nom';

  @override
  String get projectName => 'Nom du projet';

  @override
  String get optionalDescription => 'Description facultative';

  @override
  String get planning => 'Planification';

  @override
  String get clearDeadline => 'Effacer l\'échéance';

  @override
  String get projectNameRequired => 'Le nom du projet est obligatoire.';

  @override
  String get save => 'Enregistrer';

  @override
  String get deleteProject => 'Supprimer le projet ?';

  @override
  String permanentlyDeleteProject(Object projectName) {
    return 'Cette action supprimera définitivement « $projectName ».';
  }

  @override
  String get noProjectsYet => 'Aucun projet pour le moment';

  @override
  String get createProjectDescription => 'Créez un projet pour organiser un travail plus important.';

  @override
  String get projectActions => 'Actions du projet';
}
