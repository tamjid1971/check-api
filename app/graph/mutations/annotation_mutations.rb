module AnnotationMutations
  create_fields = {
    content: '!str',
    annotation_type: '!str',
    annotated_id: 'str',
    annotated_type: 'str',
    locked: 'bool'
  }

  update_fields = {
    content: 'str',
    annotation_type: 'str',
    annotated_id: 'str',
    annotated_type: 'str',
    assigned_to_id: 'int',
    locked: 'bool',
    id: '!id'
  }

  Create, Update, Destroy = GraphqlCrudOperations.define_crud_operations('annotation', create_fields, update_fields, ['source', 'project_media', 'project', 'project_source'])
end
