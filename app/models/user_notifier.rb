class UserNotifier < ActionMailer::Base
  self.delivery_method = :activerecord
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::SanitizeHelper
  extend  ActionView::Helpers::SanitizeHelper::ClassMethods # Required for rails 2.2

  include BaseHelper
  ActionMailer::Base.default_url_options[:host] = APP_URL.sub('http://', '')




 ### SENT BY MEMBERS OF SCHOOL
 def pending_membership(user,school)
    setup_sender_info
    @recipients  = "#{school.owner.email}"
    @subject     = "Redes Redu: Participação pendente"
    @sent_on     = Time.now
    @body[:user] = user
    @body[:url]  = admin_requests_school_path(school)
    @body[:school]  = school
 end

 ### SENT BY ADMIN SCHOOL
 

 
def approve_membership(user, school)
    setup_sender_info
    @recipients  = "#{user.email}"
    @subject     = "Sua participacão na rede \"#{school.name}\" foi aprovada!"
    @sent_on     = Time.now
    @body[:user] = user
    @body[:url]  = school.permalink 
    @body[:school]  = school
  end
  
def remove_membership(user, school)
    setup_sender_info
    @recipients  = "#{user.email}"
    @subject     = "Sua participacão na rede \"#{school.name}\" foi cancelada"
    @sent_on     = Time.now
    @body[:user] = user
    @body[:url]  = school.permalink 
    @body[:school]  = school
  end



 ### ADMIN REDU

  def remove_course(course)
    setup_sender_info
    @recipients  = "#{course.owner.email}"
    @subject     = "A aula \"#{course.name}\" foi removida do Redu"
    @sent_on     = Time.now
    @body[:user] = course.owner
   # @body[:url]  = course.permalink 
    @body[:course]  = course
  end
  
  
  def remove_exam(exam)
    setup_sender_info
    @recipients  = "#{exam.owner.email}"
    @subject     = "O exame \"#{exam.name}\" foi removido do Redu"
    @sent_on     = Time.now
    @body[:user] = exam.owner
   # @body[:url]  = course.permalink 
    @body[:exam]  = exam
  end
    
  def remove_user(user)
    setup_sender_info
    @recipients  = "#{user.email}"
    @subject     = "O usuário \"#{user.login}\" foi removido do Redu"
    @sent_on     = Time.now
    @body[:user] = user
  end
  

  def remove_school(school)
    setup_sender_info
    @recipients  = "#{school.owner.email}"
    @subject     = "A rede \"#{school.name}\" foi removida do Redu"
    @sent_on     = Time.now
    @body[:user] = school.owner
    @body[:school]  = school
  end


  def approve_course(course)
    setup_sender_info
    @recipients  = "#{course.owner.email}"
    @subject     = "A aula \"#{course.name}\" foi aprovada!"
    @sent_on     = Time.now
    @body[:user] = course.owner
    @body[:url]  = course.permalink 
    @body[:course]  = course
  end
  

  
  def reject_course(course, comments)
    setup_sender_info
    @recipients  = "#{course.owner.email}"
    @subject     = "A aula \"#{course.name}\" foi rejeitada para publicação no Redu"
    @sent_on     = Time.now
    @body[:user] = course.owner
    @body[:url]  = course.permalink 
    @body[:course]  = course
    @body[:comments]  = comments
  end


  def signup_invitation(email, user, message)
    setup_sender_info
    @recipients  = "#{email}"
    @subject     = "#{user.login} would like you to join #{AppConfig.community_name}!"
    @sent_on     = Time.now
    @body[:user] = user
    @body[:url]  = signup_by_id_url(user, user.invite_code)
    @body[:message] = message
  end
  
  def beta_invitation(email, beta_key)
    setup_sender_info
    @recipients  = "#{email}"
    @subject     = "Você recebeu um convite para acessar a versão beta do Redu"
    @sent_on     = Time.now
    @body[:bkey] = beta_key
    @body[:url]  = APP_URL
  end
  
  def event_notification(user, event)
    setup_sender_info
    @recipients  = "#{user.email}"
    @subject     = "Lembre-se do evento da rede #{event.school.name}"
    @sent_on     = Time.now
    @body[:user] = user
    @body[:event] = event
    @body[:event_url]  = school_event_path(event.school, event)
    @body[:school] = event.school
  end
  
  
  
  

  def friendship_request(friendship)
    setup_email(friendship.friend)
    @subject     += "#{friendship.user.login} would like to be friends with you!"
    @body[:url]  = pending_user_friendships_url(friendship.friend)
    @body[:requester] = friendship.user
  end
  
  def friendship_accepted(friendship)
    setup_email(friendship.user) 
    @subject     += "Friendship request accepted!"       
    @body[:requester] = friendship.user
    @body[:friend]    = friendship.friend
    @body[:url]       = user_url(friendship.friend)
  end
  
  def followship_notice(user, follower)
  	setup_email(user)
  	@subject     += "#{follower.login} está seguindo você no Redu"
  	@body[:follower] = follower
  end

  def comment_notice(comment)
    setup_email(comment.recipient)
    @subject     += "#{comment.username} has something to say to you on #{AppConfig.community_name}!"
    @body[:url]  = commentable_url(comment)
    @body[:comment] = comment
    @body[:commenter] = comment.user
  end
  
  def follow_up_comment_notice(user, comment)
    setup_email(user)
    @subject     += "#{comment.username} has commented on a #{comment.commentable_type} that you also commented on."
    @body[:url]  = commentable_url(comment)
    @body[:comment] = comment
    @body[:commenter] = comment.user
  end  

  def follow_up_comment_notice_anonymous(email, comment)
    @recipients  = "#{email}"
    setup_sender_info
    @subject     = "[#{AppConfig.community_name}] "
    @sent_on     = Time.now
    @subject     += "#{comment.username} has commented on a #{comment.commentable_type} that you also commented on."
    @body[:url]  = commentable_url(comment)
    @body[:comment] = comment

    @body[:unsubscribe_link] = url_for(:controller => 'comments', :action => 'unsubscribe', :comment_id => comment.id, :token => comment.token_for(email), :email => email)
  end

  def new_forum_post_notice(user, post)
     setup_email(user)
     @subject     += "#{post.user.login} has posted in a thread you are monitoring."
     @body[:url]  = "#{forum_topic_url(:forum_id => post.topic.forum, :id => post.topic, :page => post.topic.last_page)}##{post.dom_id}"
     @body[:post] = post
     @body[:author] = post.user
   end

  def signup_notification(user)
    setup_email(user)
    @subject    += "Please activate your new #{AppConfig.community_name} account"
    @body[:url]  = "#{application_url}users/activate/#{user.activation_code}"
  end
  
  def message_notification(message)
    setup_email(message.recipient)
    @subject     += "#{message.sender.login} sent you a private message!"
    @body[:message] = message
  end


  def post_recommendation(name, email, post, message = nil, current_user = nil)
    @recipients  = "#{email}"
    @sent_on     = Time.now
    setup_sender_info
    @subject     = "Check out this story on #{AppConfig.community_name}"
    content_type "text/plain"
    @body[:name] = name  
    @body[:title]  = post.title
    @body[:post] = post
    @body[:signup_link] = (current_user ?  signup_by_id_url(current_user, current_user.invite_code) : signup_url )
    @body[:message]  = message
    @body[:url]  = user_post_url(post.user, post)
    @body[:description] = truncate_words(post.post, 100, @body[:url] )     
  end
  
  def activation(user)
    setup_email(user)
    @subject    += "Your #{AppConfig.community_name} account has been activated!"
    @body[:url]  = home_url
  end
  
  def reset_password(user)
    setup_email(user)
    @subject    += "#{AppConfig.community_name} User information"
  end

  def forgot_username(user)
    setup_email(user)
    @subject    += "#{AppConfig.community_name} User information"
  end

  
  protected
  def setup_email(user)
    @recipients  = "#{user.email}"
    setup_sender_info
    @subject     = "[#{AppConfig.community_name}] "
    @sent_on     = Time.now
    @body[:user] = user
  end
  
  def setup_sender_info
    @from       = "#{AppConfig.support_email}" 
    headers     "Reply-to" => "#{AppConfig.support_email}"
    @content_type = "text/plain"           
  end
  
end
