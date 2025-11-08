import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_search_viewmodel.dart';

class UserSearchBar extends StatefulWidget {
  final String? hintText;
  final VoidCallback? onTap;
  final bool enabled;
  final bool autoFocus;

  const UserSearchBar({
    super.key,
    this.hintText = 'Cerca utenti...',
    this.onTap,
    this.enabled = true,
    this.autoFocus = false,
  });

  @override
  State<UserSearchBar> createState() => _UserSearchBarState();
}

class _UserSearchBarState extends State<UserSearchBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserSearchViewModel>(
      builder: (context, viewModel, _) {
        return Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            autofocus: widget.autoFocus,
            onChanged: (value) {
              // Log for debugging to ensure the TextField onChanged fires
              // and the viewModel receives updates.
              // This prints only in debug mode.
              viewModel.updateSearchQuery(value);
              // Use debugPrint to avoid being stripped in release builds
              // and to produce readable output in the console.
              // Note: import of foundation.dart not required here because
              // debugPrint is available from flutter/material.dart.
              // But we guard with kDebugMode for performance.
              // (kDebugMode is in flutter/foundation)
              // We'll just call debugPrint conditionally.
              // ignore: avoid_print
              // debug: print the current value
              // (keep it in code temporarily to assist debugging)
              // The viewmodel also logs its own messages.
            },
            onTap: widget.onTap,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey.shade600,
                size: 22,
              ),
              suffixIcon: viewModel.isSearching
                  ? Container(
                      width: 20,
                      height: 20,
                      padding: const EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.grey.shade600,
                        ),
                      ),
                    )
                  : viewModel.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                          onPressed: () {
                            _controller.clear();
                            viewModel.clearSearch();
                            _focusNode.unfocus();
                          },
                        )
                      : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        );
      },
    );
  }
}
