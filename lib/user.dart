class User{
  List<String> unlocked =["c08583af-357b-44e5-9173-4a1e1d3f9d7d"];
  List<UserEssence> archieved =[];
}


class UserEssence{
  final String essence_pk;
  List<String> correct;
  List<String> incorrect;

  UserEssence({required this.essence_pk, required this.correct, required this.incorrect});

  int getNumberOfQuestions(){
    // frage Supabase nach SELECT COUNT(*)FROM question WHERE question.essence_fk = this.essence_pk
    return 0;
  }

}
