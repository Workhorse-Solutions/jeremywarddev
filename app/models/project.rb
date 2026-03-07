# PORO — project data lives here, not in a database.
# Easy to maintain, no admin interface needed.
class Project
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name, :string
  attribute :slug, :string
  attribute :tagline, :string
  attribute :description, :string
  attribute :url, :string
  attribute :github_url, :string
  attribute :stack, default: []
  attribute :status, :string  # "active", "building", "shipped"
  attribute :featured, :boolean, default: false
  attribute :image, :string
  attribute :position, :integer, default: 0

  PROJECTS = [
    {
      name: "RailsFoundry",
      slug: "railsfoundry",
      tagline: "The Rails starter kit that skips the boring parts.",
      description: "A production-ready Rails 8 blueprint with authentication, billing, teams, and deployment baked in. Built from patterns I've used across dozens of projects over 20 years.",
      url: "https://railsfoundry.com",
      stack: [ "Rails 8", "Hotwire", "Tailwind", "DaisyUI", "Postgres", "Kamal" ],
      status: "active",
      featured: true,
      position: 1
    },
    {
      name: "WorkhorseOps",
      slug: "workhorseops",
      tagline: "Trailer rental management, simplified.",
      description: "Purpose-built software for managing trailer rental fleets — reservations, maintenance, customer management. Born from running an actual trailer rental business.",
      url: "https://workhorseops.com",
      stack: [ "Rails 8", "Hotwire", "Tailwind", "Postgres" ],
      status: "building",
      featured: true,
      position: 2
    },
    {
      name: "CoverText",
      slug: "covertext",
      tagline: "SMS communications for insurance agencies.",
      description: "Streamlined SMS and communications platform built specifically for independent insurance agencies. Two-way texting, automated follow-ups, and agency management system integration.",
      url: "https://covertext.com",
      stack: [ "Rails 8", "Twilio", "Hotwire", "Postgres" ],
      status: "building",
      featured: true,
      position: 3
    },
    {
      name: "ClientCompass",
      slug: "clientcompass",
      tagline: "Know your clients before they call.",
      description: "Client intelligence for insurance agencies. Surface context, history, and actionable insights the moment a client reaches out.",
      url: "#",
      stack: [ "Rails 8", "AI/ML", "Hotwire", "Postgres" ],
      status: "building",
      featured: false,
      position: 4
    },
    {
      name: "Workhorse Compliance",
      slug: "workhorse-compliance",
      tagline: "Subcontractor insurance compliance tracking.",
      description: "Automated compliance tracking for general contractors. Monitor subcontractor insurance certificates, get alerts before they expire, stay audit-ready.",
      url: "#",
      stack: [ "Rails 8", "Hotwire", "Postgres" ],
      status: "building",
      featured: false,
      position: 5
    }
  ].freeze

  class << self
    def all_projects
      PROJECTS.map { |attrs| new(attrs) }.sort_by(&:position)
    end

    def featured
      all_projects.select(&:featured)
    end

    def find_by_slug(slug)
      all_projects.find { |p| p.slug == slug }
    end
  end

  def featured?
    featured
  end

  def active?
    status == "active"
  end

  def status_badge
    case status
    when "active" then "badge-success"
    when "building" then "badge-warning"
    when "shipped" then "badge-info"
    else "badge-ghost"
    end
  end

  def status_label
    status&.capitalize
  end
end
