class MessagesController < ApplicationController

    get '/topics/:id/reply' do
        redirect_if_logged_out(session, flash, 'post a message','/topics/' + params[:id].to_s + '/reply')
        @topic = Topic.find_by(id: params[:id])
        @session = session
        erb :'/messages/new'
    end

    get '/messages/:id' do
        @message = Message.find_by(id: params[:id])
        @session = session
        erb :'/messages/show'
    end

    get '/messages/:id/edit' do
        redirect_if_logged_out(session, flash, 'edit a message','/messages/' + params[:id].to_s + '/edit')
        @message = Message.find_by(id: params[:id])
        if current_user(session) != @message.user
            flash[:message] = "Only the original poster of a message can edit it."
            redirect '/topics/' + params[:id].to_s
        end
        if @message.topic.messages.first == @message
            redirect '/topics/' + @message.topic.id.to_s + '/edit'
        else
            @session = session
            erb :'/messages/edit'
        end
    end

    get '/messages/:id/delete' do
        redirect_if_logged_out(session, flash, 'delete a message','/messages/' + params[:id].to_s + '/delete')
        @message = Message.find_by(id: params[:id])
        if current_user(session) != @message.user
            flash[:message] = "Only the original poster of a message can delete it."
            redirect '/topics/' + params[:id].to_s
        end
        if @message.topic.messages.first == @message
            redirect '/topics/' + @message.topic.id.to_s + '/delete'
        else
            @session = session
            erb :'/messages/delete'
        end
    end

    get '/messages/new' do
        flash[:message] = "New messages must be created as new topics or as replies to existing topics."
        redirect '/topics'
    end

    post '/topics/:id/reply' do
        redirect_if_logged_out(session, flash, 'post a message','/topics/' + params[:id].to_s + '/reply')
        if params[:content] == ""
            flash[:message] = "Messages can't be blank."
            redirect '/topics/' + params[:id].to_s + '/reply'
        end
        topic = Topic.find_by(id: params[:id])
        message = Message.create(user: current_user(session), content: params[:content], topic: topic)
        redirect '/topics/' + params[:id].to_s
    end

    patch '/messages/:id/edit' do
        redirect_if_logged_out(session, flash, 'edit a message','/messages/' + params[:id].to_s + '/edit')
        if params[:content] == ""
            flash[:message] = "Messages can't be blank."
            redirect '/messages/' + params[:id].to_s + '/edit'
        end
        message = Message.find_by(id: params[:id])
        if current_user(session) != message.user
            flash[:message] = "Only the original poster of a message can edit it."
            redirect '/topics/' + params[:id].to_s
        end
        message.update(content: params[:content])
        flash[:message] = "Message edited!"
        redirect '/topics/' + message.topic.id.to_s
    end

    delete '/messages/:id' do
        redirect_if_logged_out(session, flash, 'delete a message','/messages/' + params[:id].to_s + '/delete')
        message = Message.find_by(id: params[:id])
        if current_user(session) != message.user
            flash[:message] = "Only the original poster of a message can delete it."
            redirect '/topics/' + params[:id].to_s
        else
            topic = message.topic
            message.delete
            flash[:message] = "Message deleted!"
            redirect '/topics/' + topic.id.to_s
        end
    end

end