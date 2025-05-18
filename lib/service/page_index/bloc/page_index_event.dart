abstract class PageIndexEvent {}

class ChangePageIndex extends PageIndexEvent {
  final int index;

  ChangePageIndex({required this.index});
}
