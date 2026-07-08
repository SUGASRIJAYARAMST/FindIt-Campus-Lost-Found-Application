abstract class AuthRepository {
  Future<void> signInWithEmail(String email, String password);
  Future<void> signOut();
}
