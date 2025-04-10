import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? titleWidget;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;

  const CustomAppBar({super.key, this.titleWidget, this.onBackPressed, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, _) {
        if (didPop && onBackPressed != null) {
          onBackPressed!();
        }
      },
      child: AppBar(
        backgroundColor: backgroundColor ?? const Color.fromARGB(255, 243, 243, 243),
        automaticallyImplyLeading: true,
        title: Image.asset('assets/app_assets/list-n-go_logo.png', height: 50),
        centerTitle: true,
        leading:
            Navigator.canPop(context)
                ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    if (onBackPressed != null) {
                      onBackPressed!();
                    }
                    context.pop();
                  },
                )
                : null,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
