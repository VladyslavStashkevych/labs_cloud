module "label" {
  source   = "cloudposse/label/null"
  version = "0.25.0"

  environment  = var.environment
  label_order = var.label_order
}

module "course" {
  source = "./modules/dynamo_db/eu-central-1"
  context = module.label.context
  name = "course"
}

module "author" {
  source = "./modules/dynamo_db/eu-central-1"
  context = module.label.context
  name = "author"
}

module "delete-course" {
  source = "./lambda/delete-course"
  name="delete-course"
}

module "get-all-authors" {
  source = "./lambda/get-all-authors"
  name="get-all-authors"
}

module "get-all-courses" {
  source = "./lambda/get-all-courses"
  name="get-all-courses"
}

module "get-course" {
  source = "./lambda/get-course"
  name="get-course"
}

module "save-course" {
  source = "./lambda/save-course"
  name="save-course"
}

module "update-course" {
  source = "./lambda/update-course"
  name="update-course"
}

module "api-gateway-courses" {
  source         = "./api-gateway"
  names           = ["courses", "course", "authors"]
  arns           = ["${module.save-course.arn}", "${module.update-course.arn}", "${module.get-course.arn}", "${module.delete-course.arn}", "${module.get-all-courses.arn}", "${module.get-all-authors.arn}"]
  function_names = ["${module.save-course.function_name}", "${module.update-course.function_name}", "${module.get-course.function_name}", "${module.delete-course.function_name}", "${module.get-all-courses.function_name}", "${module.get-all-authors.function_name}"]
  environment    = var.environment
}