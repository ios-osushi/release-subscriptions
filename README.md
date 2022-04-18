# Release Subscriptions
[![Build & Test](https://github.com/ios-osushi/release-subscriptions/actions/workflows/build_test.yml/badge.svg)](https://github.com/ios-osushi/release-subscriptions/actions/workflows/build_test.yml)
[![Scheduled Run](https://github.com/ios-osushi/release-subscriptions/actions/workflows/scheduled.yml/badge.svg)](https://github.com/ios-osushi/release-subscriptions/actions/workflows/scheduled.yml)

iOS Osushi が GitHub 上の各リポジトリのリリース情報を定期的に、自動で取得するために使用するツールです。

## リリース情報自動取得対象のリポジトリ
<!-- BEGIN LIST OF REPOSITORIES (AUTOMATICALLY OUTPUT) -->
<!-- END LIST OF REPOSITORIES (AUTOMATICALLY OUTPUT) -->

なお、これらは `ReleaseSubscriptions.yml` に列挙されています。

- `kind`: Slack Webhook URL の向き先を指定
  - `primary`（主としてオーナーが Apple のリポジトリ）
  - `secondary`（主としてオーナーが Apple 以外のリポジトリ）
- `case`: リリース情報が提供されている手法を指定
  - `releases`（GitHub の「リリース」）
  - `tags`（GitHub の「タグ」）
- `name`: リポジトリで公開されているソフトウェアの名前
- `owner`: リポジトリのオーナー
- `repo`: リポジトリの名称

列挙の順番（ソート順）のルールは以下のとおりです。

1. `kind` が `primary` → `secondary` の順
1. `owner` の大文字小文字区別なし昇順
1. `repo` の大文字小文字区別なし昇順

## 動作環境
macOS 10.15 以降の CLI および Linux の CLI で、Swift 5.6 以降。

GitHub Actions で定期実行し、リリース情報を Slack Webhook に送信することを想定しています。
