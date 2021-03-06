#' @title 
#' Get Package Description
#'
#' @description 
#' Retrieves the content of a package's DESCRIPTION file.
#' 
#' @param from \strong{Signature argument}.
#'    Object containing source information.
#' @param fields \code{Signature argument}.
#'    Object containing field name information.
#' @param class_type \code{\link{character}}.
#' @param drop \code{logical}.
#'    If \code{TRUE} and the length of \code{fields} is 1, then a single 
#'    character string with the value of the respective field is returned 
#'    instead of an object of class \code{packageDescription}.
#' @param encoding \code{character}.
#'    If there is an Encoding field, to what encoding should re-encoding be 
#'    attempted? If NA, no re-encoding. The other values are as used by 
#'    \code{\link{iconv}}, so the default \code{""} indicates the encoding of 
#'    the current locale.
#' @param strict \code{logical}.
#'    \code{TRUE}: certain constellations trigger an error. 
#'    \code{FALSE} (default): these 
#'    conditions are only reflected by a return value of \code{NA} and 
#'    possibly a corresponding warning. 
#' @param ... Further arguments passed to subsequent functions/methods.
#'    In particular:
#'    \code{\link[utils]{packageDescription}}.
#' @example inst/examples/getPackageDescription.r
#' @seealso \code{
#'    \link[descriptionr]{getPackageDescription-character-character-method}
#' }
#' @template author
#' @template references
#' @export
setGeneric(name="getPackageDescription", 
  signature = c(
    "from",
    "fields"
  ),
  def = function(
    from = ".",
    fields = character(),
    drop = TRUE,
    encoding = "",
    strict = FALSE,
    ...
  ) {
  standardGeneric("getPackageDescription")
})

#' @title 
#' Get Package Description
#'
#' @description 
#' See generic: \code{\link[descriptionr]{getPackageDescription}}
#' 
#' @inheritParams getPackageDescription
#' @param from \code{\link{character}}.
#' @param fields \code{\link{character}}.  
#     A vector giving the tags of fields to return (if other fields occur in 
#     the file they are ignored).  
#' @return \code{character}. Content of \code{DESCRIPTION} file.
#' @example inst/examples/getPackageDescription.r
#' @seealso \code{
#'    \link[descriptionr]{getPackageDescription}
#' }
#' @template author
#' @template references
#' @export
#' @import conditionr
setMethod(f = "getPackageDescription", 
  signature = signature(
      from = "character",
      fields = "character"
  ), 
  definition = function(
      from,
      fields,
      drop,
      encoding,
      strict,
      ...
  ) {
  
  if (!isPackageInstalled(pkg = from, simplified = TRUE)) {
    is_dir <- file.info(from)$isdir
    if (is.na(is_dir)) {
      conditionr::signalCondition(
        condition = "InvalidArgumentValue",
        msg = c(
          "Invalid argument value for 'from'",
          Details = "neither package name nor directory path"
        ),
        ns = "descriptionr",
        type = "error"
      )
    }  
    if (is_dir) {
      from <- file.path(from, "DESCRIPTION")
    }
    out <- getPackageDescriptionFromFile(
      from = from,
      fields = fields,
      drop = drop,
      encoding = encoding,
      strict = strict,
      validate = FALSE
    )
  } else {
    if (!length(fields)) {
      fields <- NULL
    }
    
    ## Check if loaded //
    pkgs_loaded <- .packages(all.available = FALSE)
    if (from %in% pkgs_loaded) {
      out <- packageDescription(
        pkg = from,
        fields = fields,
        drop = drop,
        encoding = encoding,
        ...
      )
    } else {
      from_1 <- file.path(.libPaths()[1], from, "DESCRIPTION")
      out <- getPackageDescriptionFromFile(
        from = from_1, 
        fields = as.character(fields),
        drop = drop
      )
    }
    
    ## If no direct matches //
    if (is.na(out) && !is.null(fields)) {
      if (from %in% pkgs_loaded) {
        desc <- packageDescription(pkg = from)
      } else {
        from_1 <- file.path(.libPaths()[1], from, "DESCRIPTION")
        desc <- getPackageDescriptionFromFile(from = from_1)
      }
      
      if (!strict) {
        fields_1 <- inferDescriptionFieldName(from = desc, pattern = fields)
        if (length(fields_1)) {
          conditionr::signalCondition(
            condition = "InferringViaRegularExpressionMatch",
            msg = c(
              "Inferring correct field names via regular expression match",
              "Original field names" = fields,
              "Inferred field names" = fields_1
            ),
            ns = "descriptionr",
            type = "warning"
          )
          
          out <- packageDescription(
            pkg = from,
            fields = fields_1,
            drop = drop,
            encoding = encoding,
            ...
          )
        } else {
          out <- NA
        }
      } else {
        out <- NA
      }
    }
  }
  out
  
  } 
)

#' @title 
#' Get Package Description
#'
#' @description 
#' See generic: \code{\link[descriptionr]{getPackageDescription}}
#' 
#' @inheritParams getPackageDescription
#' @param from \code{\link{missing}}.  
#' @param fields \code{\link{character}}.  
#     See signature \code{character,character}
#' @return See method 
#'    \code{\link[descriptionr]{getPackageDescription-character-character-method}}.
#' @example inst/examples/getPackageDescription.r
#' @seealso \code{
#'    \link[descriptionr]{getPackageDescription}
#' }
#' @template author
#' @template references
#' @export
setMethod(f = "getPackageDescription", 
  signature = signature(
    from = "missing",
    fields = "character"
  ), 
  definition = function(
    from,
    fields,
    drop,
    encoding,
    strict,
    ...
  ) {
  
  getPackageDescription(
    from = from,
    fields = fields,
    drop = drop,
    encoding = encoding,
    strict = strict,
    ...
  )
  
  } 
)

#' @title 
#' Get Package Description
#'
#' @description 
#' See generic: \code{\link[descriptionr]{getPackageDescription}}
#' 
#' @inheritParams getPackageDescription
#' @param from \code{\link{missing}}.  
#' @param fields \code{\link{missing}}.  
#' @return See method 
#'    \code{\link[descriptionr]{getPackageDescription-character-character-method}}.
#' @example inst/examples/getPackageDescription.r
#' @seealso \code{
#'    \link[descriptionr]{getPackageDescription}
#' }
#' @template author
#' @template references
#' @export
setMethod(f = "getPackageDescription", 
  signature = signature(
    from = "missing",
    fields = "missing"
  ), 
  definition = function(
    from,
    fields,
    drop,
    encoding,
    strict,
    ...
  ) {
  
  getPackageDescription(
    from = from,
    fields = fields,
    drop = drop,
    encoding = encoding,
    strict = strict,
    ...
  )
  
  } 
)

#' @title 
#' Get Package Description
#'
#' @description 
#' See generic: \code{\link[descriptionr]{getPackageDescription}}
#' 
#' @inheritParams getPackageDescription
#' @param from \code{\link{character}}.  
#     See signature \code{character,character}
#' @param fields \code{\link{missing}}.  
#' @return See method 
#'    \code{\link[descriptionr]{getPackageDescription-character-character-method}}.
#' @example inst/examples/getPackageDescription.r
#' @seealso \code{
#'    \link[descriptionr]{getPackageDescription}
#' }
#' @template author
#' @template references
#' @export
setMethod(f = "getPackageDescription", 
  signature = signature(
    from = "character",
    fields = "missing"
  ), 
  definition = function(
    from,
    fields,
    drop,
    encoding,
    strict,
    ...
  ) {
  
  getPackageDescription(
    from = from,
    fields = fields,
    drop = drop,
    encoding = encoding,
    strict = strict,
    ...
  )
  
  } 
)
