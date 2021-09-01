class TopicsController < ApplicationController

    get '/topics' do
        @session = session
        @topics = Topic.all.sort_by {|topic| topic.messages.last.created_at}
        erb :'/topics/index'
    end

    get '/topics/new' do
        if !Helper.logged_in?(session)
            flash[:message] = "You must be logged in to create a new topic."
            session[:failed_due_to_not_logged_in] = '/topics/new'
            redirect '/login'
        end
        @session = session
        erb :'/topics/new'
    end

    get '/topics/:id' do
        @topic = Topic.find_by(id: params[:id])
        @session = session
        erb :'/tweets/show_tweet'
    end

    get '/topics/:id/edit' do
        if !Helper.logged_in?(session)
            flash[:message] = "You must be logged in to edit topics."
            session[:failed_due_to_not_logged_in] = '/topics/' + params[:id].to_s + '/edit'
            redirect '/login'
        end
        @topic = Topic.find_by(id: params[:id])
        if Helper.current_user(session) == @topic.op
            @session = session
            erb :'/topics/edit'
        else
            flash[:message] = "Only the original poster of a topic can edit it."
            redirect '/topics/' + params[:id]
        end
    end

    post '/topics/new' do
        if !Helper.logged_in?(session)
            flash[:message] = "You must be logged in to create a new topic."
            session[:failed_due_to_not_logged_in] = '/topics/new'
            redirect '/login'
        end
        if params[:topic][:title] == "" || params[:topic][:first_message] == ""
            flash[:message] = "The topic title and the first message can't be blank."
            redirect '/tweets/new'
        end
        topic = Topic.create(params[:topic])
        flash[:message] = "New topic posted!"
        redirect '/topics/' + topic.id.to_s
    end

    get '/topics/:id/delete' do
        if !Helper.logged_in?(session)
            flash[:message] = "You must be logged in to delete a topic!"
            session[:failed_due_to_not_logged_in] = '/topics/' + params[:id].to_s + '/delete'
            redirect '/login'
        end
        @topic = Topic.find_by(id: params[:id])
        if Helper.current_user(session) == @topic.op
            @session = session
            erb :'/topics/delete'
        else
            flash[:message] = "Only the original poster of a topic can delete it."
            redirect '/topics/' + params[:id]
        end
    end

    delete '/topics/:id' do
        if !Helper.logged_in?(session)
            flash[:message] = "You must be logged in to delete a topic!"
            session[:failed_due_to_not_logged_in] = '/topics' + params[:id].to_s + '/delete'
            redirect '/login'
        end
        topic = Topic.find_by(id: params[:id])
        if Helper.current_user(session) == topic.op
            topic.messages.each do |message|
                message.delete
            end
            topic.delete
            flash[:message] = "Topic deleted!"
            redirect '/topics'
        else
            flash[:message] = "Only the original poster of a topic can delete it."
            redirect '/topics/' + params[:id]
        end
    end

    patch '/tweets/:id' do
        if !Helper.logged_in?(session)
            flash[:message] = "You must be logged in to edit topics."
            session[:failed_due_to_not_logged_in] = '/topics/' + params[:id].to_s + '/edit'
            redirect '/login'
        end
        if params[:topic][:title] == "" || params[:topic][:first_message] == ""
            flash[:message] = "The topic title and the first message can't be made blank."
            redirect '/topics/' + params[:id] + '/edit'
        end
        topic = Topic.find_by(id: params[:id])
        if Helper.current_user(session) == topic.op
            topic.update(params[:topic])
            flash[:message] = "Topic updated!"
        else
            flash[:message] = "Only the original poster of a topic can edit it."
        end
        redirect '/topics/' + params[:id]
    end


end