class TerminalStatusMailer < ApplicationMailer
	layout nil

	def notify(annotated, author, status)
		team = annotated.project.team
		recipients = team.recipients(author, ['editor', 'owner'])
		@project_media = annotated
		@info = {
      author: author.present? ? author.name : '',
      title: annotated.title,
      status: status
    }
    subject = I18n.t(:mail_subject_update_status, team: team.name, project: annotated.project.title, status: status)
		self.send_email_to_recipients(recipients, subject, 'terminal_status')
	end

end
