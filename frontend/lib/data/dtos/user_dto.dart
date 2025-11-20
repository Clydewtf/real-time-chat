class UserDto {
  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;

  UserDto({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as String,
      username: (json['username'] ?? '') as String,
      displayName: (json['display_name'] ?? '') as String,
      avatarUrl: (json['avatar_url'] as String?)?.isNotEmpty == true
          ? json['avatar_url'] as String
          : 'https://i.pravatar.cc/150',
    );
  }
}