# takes in two lists, one of single-letter categories and another with book code and quantity formatted as "BADF 20"
# returns a string with the categories and quantities of each

def stock_list(list_of_art, list_of_cat):
    if len(list_of_art) == 0:
        return ""
    
    out_dict = dict()
    
    # build dictionary from categories
    for cat in list_of_cat:
        out_dict[cat] = 0

    # sort codes into the categories dictionary
    for art in list_of_art:
        cat_code = art[:1]
        quantity = int(art.split(" ")[1])

        # don't sort this unless the category exists
        if cat_code in out_dict:
            out_dict[cat_code] += quantity

    # build output string
    out_string = ""
    for key in out_dict:
        if not out_string == "":
            out_string += " - "
        out_string += "(" + key + " : " + str(out_dict[key]) + ")"

    return out_string
