SimpleCov.configure do
  # 設定最低覆蓋率門檻
  minimum_coverage 80

  # 當覆蓋率低於門檻時，exit 1 (讓 CI 失敗)
  minimum_coverage_by_file 70

  # 設定報告格式
  formatter SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::SimpleFormatter
  ])

  # 排除特定檔案
  add_filter '/spec/'
  add_filter '/config/'
  add_filter '/db/'
  add_filter '/vendor/'
  add_filter '/bin/'
  add_filter '/app/mailers/'
  add_filter '/app/jobs/'

  # 群組設定
  add_group 'Models', 'app/models'
  add_group 'Controllers', 'app/controllers'
  add_group 'Services', 'app/services'
  add_group 'Forms', 'app/forms'
  # add_group 'Jobs', 'app/jobs'
  # add_group 'Mailers', 'app/mailers'

  # 追蹤分支覆蓋率
  enable_coverage :branch
end
