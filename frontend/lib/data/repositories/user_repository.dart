import '../datasources/remote/user/user_remote_datasource.dart';
import '../dtos/user_dto.dart';

class UserRepository {
  final UserRemoteDatasource remote;

  UserRepository({required this.remote});

  Future<List<UserDto>> searchUsers(String query) async {
    final rawList = await remote.searchUsers(query);
    return rawList.map((e) => UserDto.fromJson(e)).toList();
  }

  Future<UserDto?> getUser(String userId) async {
    try {
      final raw = await remote.getUserById(userId);
      if (raw == null) return null;
      return UserDto.fromJson(raw);
    } catch (e) {
      throw Exception("$e");
    }
  }
}
