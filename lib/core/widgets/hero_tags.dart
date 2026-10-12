/// Hero tags shared by list items and the screens they open.
abstract final class HeroTags {
  static String entryIcon(String id) => 'entry-icon-$id';
  static String entryTitle(String id) => 'entry-title-$id';
  static String reminderIcon(String id) => 'reminder-icon-$id';
  static String reminderTitle(String id) => 'reminder-title-$id';
  static String statTile(Object key) => 'stat-tile-$key';
}
