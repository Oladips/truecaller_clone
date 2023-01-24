import 'package:objectbox/objectbox.dart';

@Entity()
class Phones {
  int id;
  String number;
  String normalizedNumber;
  final contact = ToOne<Contacts>();

  Phones({
    this.id = 0,
    required this.normalizedNumber,
    required this.number,
  });
}

class Email {
  int id;
  String email;
  final contact = ToOne<Contacts>();

  Email({
    this.id = 0,
    required this.email,
  });
}

@Entity()
class Contacts {
  int id;
  String? contactId;
  String displayName;
  String? first;
  String? last;
  String? middle;
  String? prefix;
  String? suffix;
  String? nickname;
  String? firstPhonetic;
  String? lastPhonetic;
  String? middlePhonetic;

  @Backlink("contact")
  final phone = ToMany<Phones>();
  // @Backlink("contact")
  // final email = ToMany<Email>();
  // List<String> emails;
  // Uint8List? thumbnail;
  // Uint8List? photo;
  // Uint8List? get photoOrThumbnail => photo ?? thumbnail;
  // bool isStarred;
  // Name name;
  // List<Phone> phones;
  // List<Address> addresses;
  // List<Organization> organizations;
  // List<Website> websites;
  // List<SocialMedia> socialMedias;
  // List<Event> events;
  // List<Note> notes;
  // List<Account> accounts;
  // List<Group> groups;
  // bool thumbnailFetched = true;
  // bool photoFetched = true;
  // bool isUnified = true;
  // bool propertiesFetched = true;

  Contacts({
    required this.displayName,
    this.first,
    this.last,
    this.middle,
    this.prefix,
    this.suffix,
    this.lastPhonetic,
    this.middlePhonetic,
    this.nickname,
    this.firstPhonetic,
    this.id = 0,
    this.contactId,
  });
}
