import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum HomeTab {
  home(filledIcon: Icons.home_filled, unfilledIcon: Icons.home_outlined),
  folder(filledIcon: Icons.folder, unfilledIcon: Icons.folder_outlined),
  settings(filledIcon: Icons.settings, unfilledIcon: Icons.settings_outlined);

  const HomeTab({required this.filledIcon, required this.unfilledIcon});

  final IconData filledIcon;
  final IconData unfilledIcon;
}

final class HomeState extends Equatable {
  const HomeState({this.tab = HomeTab.home});

  final HomeTab tab;

  @override
  List<Object> get props => [tab];
}
