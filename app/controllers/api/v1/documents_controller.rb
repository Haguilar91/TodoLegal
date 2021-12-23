class Api::V1::DocumentsController < ApplicationController
  protect_from_forgery with: :null_session
  include ApplicationHelper
  before_action :doorkeeper_authorize!, :document_exists!, only: [:get_document]
  skip_before_action :doorkeeper_authorize!, unless: :has_access_token?
  
  def get_document
    json_document = get_document_json
    can_access_document = true
    user_id_str = ""
    if params[:access_token]
      user = User.find_by_id(doorkeeper_token.resource_owner_id)
      user_id_str = user.id.to_s
    end

    if user && current_user_type(user) == "pro"
      json_document = json_document.merge(file: url_for(@document.original_file))
    else
      json_document = json_document.merge(file: "")
    end

    #user_document_download_tracker = get_user_document_download_tracker(user_id_str)
    #can_access_document = can_access_documents(user_document_download_tracker, current_user_type(user))

    #if can_access_document and @document.original_file.attached?
    #  json_document = json_document.merge(file: url_for(@document.original_file))
    #else
    #  json_document = json_document.merge(file: "")
    #end

    issuer_name = get_issuer_name @document.id

    render json: {"document": json_document,
      "issuer": issuer_name,
      "tags": get_document_tags,
      "related_documents": get_related_documents,
      "can_access": can_access_document,
      "user_type": current_user_type(user),
    }
  end

  def get_documents
    limit = 100
    if !params["limit"].blank?
      limit = params["limit"]
    end
    query = "*"
    if !params["query"].blank?
      query = params["query"]
    end
    from = nil
    to = nil
    if !params["from"].blank?
      begin
        Date.parse(params["from"])
        from = params["from"]
      rescue ArgumentError
      end
    end
    if !params["to"].blank?
      begin
        Date.parse(params["to"])
        to = params["to"]
      rescue ArgumentError
      end
    end

    searchkick_where = {
      publication_date: {gte: from, lte: to},
      name: {not: "Gaceta"},
    }

    if !params["tags"].blank? and params["tags"].kind_of?(Array)
      document_ids = []
      params["tags"].each do |tag_name|
        tag = Tag.find_by_name(tag_name)
        if tag
          document_ids = []
          tag.documents.each do |document|
            document_ids.push(document.id)
          end
          document_ids = document_ids.uniq
        end
      end
      searchkick_where[:id] = {in: document_ids}
    end

    documents = Document.search(
      query,
      fields: [:name, :publication_number, :description],
      where: searchkick_where,
      limit: limit,
      offset: params["offset"].to_i,
      order: {publication_date: :desc})

    total_count = documents.total_count
    documents = documents.to_json
    documents = JSON.parse(documents)

    documents.each do | document |
      tags = []
      document_tags = DocumentTag.where(document_id: document["id"].to_i)
      if document_tags.first
        puts document_tags.first.tag.name
      end
      document_tags.each do |document_tag|
        if document_tag
          tags.push({"name": document_tag.tag.name, "type": document_tag.tag.tag_type.name})
        end
      end
      issuer_name = get_issuer_name document["id"].to_i
      document["issuer"] = issuer_name
      document["tags"] = tags
    end

    render json: { "documents": documents, "count": total_count }
  end

protected
  def get_issuer_name document_id
    issuer = IssuerDocumentTag.find_by_document_id(document_id)
    if issuer
      issuer_name = issuer.tag.name
    end
  end

  def get_document_json
    related_documents = Document.where(publication_number: @document.publication_number)
    json_document = @document.as_json
    judgement_auxiliary = JudgementAuxiliary.find_by_document_id(@document.id)
    if judgement_auxiliary
      json_document["applicable_laws"] = judgement_auxiliary.aplicable_laws
    end
    return json_document
  end

  def get_document_tags
    tags = []
    @document.tags.each do |tag|
      tags.push({"name": tag.name, "type": tag.tag_type.name})
    end
    return tags
  end

  def get_related_documents
    Document.where(publication_number: @document.publication_number)
  end

  def document_exists!
    @document = Document.find_by_id(params[:id])
    if !@document
      render json: {"error": "Document not found."}
      return
    end
  end

  def has_access_token?
    return params[:access_token]
  end
end
