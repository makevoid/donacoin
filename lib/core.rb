# Core.download ids, radio_selection
# Core.download [1, 2, 3], "report|contract"

require 'mechanize'
require_relative 'mechanize_utils'

class OutsideVPNError < Net::HTTP::Persistent::Error
  def message; "Please connect to the VPN first to use the downloader"; end
end

class Core

  include FileUtils

  HOST_LOGIN = "158.167.146.140"
  HOST_CRIS = "158.167.211.53"
  CRIS_ROOT = "http://#{HOST_CRIS}:6081/EUROPEAID/cris"

  # http://158.167.211.53:6081/EUROPEAID/cris

  PATH = File.expand_path "../", __FILE__
  LOGIN_URL = "https://#{HOST_LOGIN}:7002/cas/login?loginRequestId=ECAS_LR-4685921-VYzSmxtEZmttfK2mgc1ZPcdwUwDWJnD3vzQOocUhG6U0-wkGjxchnStjMueiTZpKjZG-0g6jJpOctfA48XMyP0wCMG"
  CRIS_URL = "#{CRIS_ROOT}/saisie/login/home.cfm"
  USER = ""
  PASS = ""

  JAR_PATH = File.expand_path "../../../", __FILE__

  LOAD_COOKIE = false
  COOKIE_FILE = "cookies.yml"

  OUTPUT_DIR = "CRIS_Downloads"


  attr_reader :ids, :type, :status

  def initialize
    login
  end

  def load(ids, type)
    @ids = ids.split(" ")
    @type = type # contract | decision
  end

  def ids_plain
    @ids.join(", ")
  end

  def agent
    @agent ||= load_agent
  end

  def login
    unless LOAD_COOKIE
      page = agent.get LOGIN_URL

      agent.set_cookies domain: HOST_LOGIN, path: "/cas", cookies: [{"MyEcasDomain" => "external"}]

      page = agent.get LOGIN_URL

      form = page.forms_with(id: "loginForm").first
      form.domain = "external"
      form.username = USER
      form.password = PASS
      page = form.submit

      page = agent.get CRIS_URL

      link = page.search("noscript a").first["href"]

      page = agent.get "https://158.167.146.140:7002/#{link}"

      agent.cookie_jar.save_as COOKIE_FILE
    else
      agent.cookie_jar.load COOKIE_FILE
    end

    @status = "logged in!"
  end

  def download

    agent.pluggable_parser.default = Mechanize::Download # needed?

    #contracts_url = "CRIS_ROOT/saisie/contrat/contrat_select.cfm?action=new"
    #page = agent.get contracts_url

    if type == "decision"
      @ids.each do |decision_id|
        download_decision decision_id
        download_attached_documents decision_id
        download_monitoring_reports decision_id
      end
    else
      @ids.each do |contract_id|
        download_attached_documents contract_id
        download_monitoring_reports contract_id
        download_contract contract_id
      end
    end

    # puts ""
    # puts "completed!"
    @status = "download finished of #{type}(s) #{@ids.join(", ")}"
  end

  private

  # downloads

  def download_decision(decision_id)
    @status = "downloading decision #{decision_id}"
    # puts "downloading decision #{decision_id}"
    decision_search_url = "#{CRIS_ROOT}/saisie/decision/decision_edf.cfm?action=ShowFromList&fct=&Key=21190&CFID=11000764&CFTOKEN=79dce61337434d42-3F462448-B8A2-BBB5-FE4FEA8CDB5DF5FF&jsessionid=7151c821c247890eaf48357b6633787c5d45TR"

    decision_url = "http://158.167.211.53:6081/EUROPEAID/cris/saisie/decision/report_select.cfm?key=#{decision_id}&report=FP&dom=FED"

    page = agent.get decision_url
    form = page.forms.first
    form.fldJal = "on"
    form.fldVis = "on"
    form.fldAnal = "on"
    form.fldCtr = "on"
    form.fldFin = "on"
    form.fldStat = "on"
    form.fldAvt = "on"
    form.fldVis = "on"
    form.fldDoc = "on"
    page = form.submit
    path = "#{outer_path}/#{OUTPUT_DIR}/decision_#{decision_id}/fiche_cris_decision_#{decision_id}.pdf"
    rm_f path
    page.save path
  end

  def download_monitoring_reports(contract_id)
    # external monitoring evaluation audits
    evaluation_url = "#{CRIS_ROOT}/saisie/decision/monitor_upper.cfm?key=0&fkey_nsq=#{contract_id}&entt_cod=#{type == "contract" ? "CTR" : "DEC"}"

    page = agent.get evaluation_url

    page.search("table table table table table table td.Xsmall a").each_with_index do |link, idx|

      report_title = filenamize(link.inner_text)
      report_id = link["href"].match(/romm_nsq=(\d+)&/)
      if report_id
        report_id = report_id[1]
        @status = "downloading #{type} #{contract_id} monitoring report #{report_id}"

        report_url = "#{CRIS_ROOT}/saisie/rom/report_geninfo.cfm?action=PRINT&romm_nsq=#{report_id}"

        contract_dir = type == "contract" ? contract_id : "decision_#{contract_id}"
        save_attachment contract_dir, "monitoring_reports/#{report_title}.pdf", report_url

        download_mr_attachments contract_id, report_id, report_title
      else
        puts "failed to obtain report_id from #{link["href"]}"
      end
    end
  end

  def download_mr_attachments(contract_id, report_id, report_title)
    download_attached_documents contract_id, { id: report_id, title: report_title }
  end


  def download_contract(contract_id)
    @status = "downloading contract #{contract_id}"
    # contract_url = "#{CRIS_ROOT}/saisie/contrat/contratsv.cfm?action=ShowFromList&fct=&key=#{contract_id}&CFID=10698054&CFTOKEN=c93076ed99707462-9A0F8C9F-0B68-BD73-6C13933799C255CA&jsessionid=71516812fb3a89a0a21f28193965105b6566TR"
    # page = agent.get contract_url

    contract_form_rtf_url = "#{CRIS_ROOT}/saisie/contrat/report_select.cfm?key=#{contract_id}&report=FC&desformat=RTF&mimetype=application/msword"
    contract_form_pdf_url = "#{CRIS_ROOT}/saisie/contrat/report_select.cfm?key=#{contract_id}&report=FC"

    save_attachment contract_id, "fiche_cris_contract_#{contract_id}.pdf", contract_form_pdf_url
    save_attachment contract_id, "fiche_cris_contract_#{contract_id}.rtf", contract_form_rtf_url
  end

  def download_attached_documents(contract_id, report=nil)
    # puts "downloading attached documents"
    # attached documents:
    # [0] wkhd_num?
    # http://158.167.211.53:6081/EUROPEAID/cris/saisie/document/document_upper.cfm?entt_cod=CTR&fkey_nsq=#{contract_id}&wkhd_num=0&CCTP_COD=SV


    attached_documents_url = if type == "contract"
      "#{CRIS_ROOT}/saisie/document/document_upper.cfm?entt_cod=CTR&fkey_nsq=#{contract_id}&wkhd_num=0&CCTP_COD=SV"
    else
      "#{CRIS_ROOT}/saisie/document/document_upper.cfm?entt_cod=DEC&fkey_nsq=#{contract_id}&wkhd_num=0&CCTP_COD=" # decision_id
    end

    attached_documents_url = "#{CRIS_ROOT}/saisie/document/document_upper.cfm?entt_cod=ROM&fkey_nsq=#{report[:id]}&wkhd_num=0&CCTP_COD=" if report

    page = agent.get attached_documents_url

    links = page.search "table table table table table table td a"
    links.each do |link|

      document_title = filenamize(link.inner_text)
      match = link["onclick"].match(/docu_nsq=(\d+)&/)
      if match
        file_ext = link["onclick"].match(/doex_cod=(\w+)/)
        file_ext = file_ext[1]
        document_id = match[1]
        @status = unless report
          "downloading #{type} #{contract_id} attached document #{document_id}"
        else
          "downloading report #{report[:id]} attached document #{document_id}"
        end

        document_url = "#{CRIS_ROOT}/saisie/document/inc_extract_document.cfm?entt_cod=CTR&docu_nsq=#{document_id}&doex_cod=#{file_ext}"
        contract_dir = type == "contract" ? contract_id : "decision_#{contract_id}"
        report_dir = ""
        report_dir = "monitoring_reports/#{report[:title]}_" if report
        dir = "#{report_dir}attached_documents/#{document_title}.#{file_ext.downcase}"
        save_attachment contract_dir, dir, document_url
      else
        puts "Can't match 'attached document' with name '#{document_title}' for contract #{contract_id}"
      end
    end
  end


  # others

  require 'logger'

  def load_agent
    agent = Mechanize.new
    #agent.log = Logger.new STDOUT
    agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    agent.user_agent = "Windows IE 9"
    agent.read_timeout = 20
    agent
  end

  def inside_jar?
    File.basename(JAR_PATH) =~ /jar!$/
  end

  def outer_path
    if inside_jar?
      path = File.expand_path "../"*4, __FILE__
      path.sub(/^file:/, '')
    else
      File.expand_path "../../", __FILE__
    end
  end

  def filenamize(string)
    string.downcase.gsub(/\W+/, '_')
  end

  def make_dir(dir, contract_id)
    dir = "#{outer_path}/#{OUTPUT_DIR}/#{contract_id}/#{dir}"
    mkdir_p dir
  end

  def save_attachment(contract_id, name, url, params=nil)
    dir = "#{outer_path}/#{OUTPUT_DIR}/#{contract_id}"
    mkdir_p dir
    path = "#{dir}/#{name}"
    page = unless params
      agent.get url
    else
      agent.post url, params
    end
    rm_f path
    page.save path
  end

  def preview(page, delete_scripts=true)
    chrome = 'C:\Users\Administrator\AppData\Local\Google\Chrome\Application\chrome.exe'
    dir = Dir.pwd
    body = page.body
    page = Nokogiri::HTML(body)
    page.search("script").remove
    body = page.to_html
    File.open("./temp.html", "w"){ |f| f.write body }

    `#{chrome} #{dir}/temp.html`
  end

  def clean_riders(contract_id)
    riders = ["rider.pdf", "rider_cover.pdf", "rider.rtf", "rider_cover.rtf"]
    riders.each do |rider|
      path = "#{outer_path}/#{OUTPUT_DIR}/#{contract_id}/#{rider}"
      contents = nil
      File.open(path) { |f| contents = f.readline }
      if contents =~ /^<html>/i
        rm_f path
      end
    end
  end

end