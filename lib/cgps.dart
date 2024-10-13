import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

class CGPS extends StatefulWidget {
  const CGPS({super.key});

  @override
  State<CGPS> createState() => _CGPSState();
}

class _CGPSState extends State<CGPS> {
  final GlobalKey webViewKey = GlobalKey();
  late InAppWebViewController inAppWebViewController;
  double _progress = 0.0;
  String _currentUrl = "https://chandkhaligovtprimaryschool.onebyzeroedu.com/";
  PullToRefreshController? pullToRefreshController;
  PullToRefreshSettings pullToRefreshSettings = PullToRefreshSettings(
    color: Colors.blue,
  );
  void initState() {
    // TODO: implement initState
    pullToRefreshController = kIsWeb
        ? null
        : PullToRefreshController(
            settings: pullToRefreshSettings,
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                inAppWebViewController?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS) {
                inAppWebViewController?.loadUrl(
                    urlRequest: URLRequest(
                        url: await inAppWebViewController?.getUrl()));
              }
            },
          );
    super.initState();
  }

  Future<void> _launchInBrowser(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print("Could not launch...");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await inAppWebViewController.canGoBack()) {
          inAppWebViewController.goBack();
          return false;
        }
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          body: Stack(children: [
            InAppWebView(
              key: webViewKey,
              initialSettings: InAppWebViewSettings(
                transparentBackground: true,
                javaScriptCanOpenWindowsAutomatically: true,
                thirdPartyCookiesEnabled: true,
                supportMultipleWindows: true,
                javaScriptEnabled: true,
                applicationNameForUserAgent: "Onebyzero Edu",
                userAgent: 'random',
              ),
              pullToRefreshController: pullToRefreshController,
              initialUrlRequest: URLRequest(
                url: WebUri.uri(Uri.parse(_currentUrl)), // Corrected here
              ),
              onWebViewCreated: (InAppWebViewController controller) {
                inAppWebViewController = controller;
              },
              onProgressChanged:
                  (InAppWebViewController controller, int progress) {
                setState(() {
                  _progress = progress / 100;
                  if (progress == 100) {
                    pullToRefreshController?.endRefreshing();
                  }
                });
              },
              onLoadStop: (controller, url) {
                pullToRefreshController?.endRefreshing();
              },
              onReceivedError: (controller, request, error) {
                pullToRefreshController?.endRefreshing();
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                var uri = navigationAction.request.url!;
                print("Navigating to: $uri");

                if (uri.toString().endsWith(".pdf") ||
                    uri.toString().contains("wa.me/+8801569134868") ||
                    uri.toString().contains("m.me/116328604722401") ||
                    uri.toString().contains("facebook.com") ||
                    uri.toString().contains("linkedin.com") ||
                    uri.toString().contains("gmail.com")) {
                  print("Opening in external browser: $uri");
                  await _launchInBrowser(uri.toString());
                  return NavigationActionPolicy.CANCEL;
                }

                return NavigationActionPolicy.ALLOW;
              },
            ),
            _progress < 1
                ? LinearProgressIndicator(
                    value: _progress,
                  )
                : SizedBox(),
          ]),
        ),
      ),
    );
  }
}
