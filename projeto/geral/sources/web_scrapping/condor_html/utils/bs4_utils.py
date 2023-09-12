from bs4 import Tag

def get_nested_dict_attr_value(tag: Tag, attr: str):
    attr_dict = {}
    if hasattr(tag, 'children'):
        for subtag in tag.children:
            if hasattr(subtag, 'attrs') and attr in subtag.attrs:
                classes = " ".join(subtag.attrs[attr])
                attr_dict[classes] = subtag.get_text()
            attr_dict.update(get_nested_dict_attr_value(subtag, attr))
    return attr_dict