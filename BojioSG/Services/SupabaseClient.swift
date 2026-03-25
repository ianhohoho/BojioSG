import Foundation
import Supabase

enum SupabaseConfig {
    static let url = URL(string: "https://psnwbnvupwoousudrtuz.supabase.co")!
    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBzbndibnZ1cHdvb3VzdWRydHV6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM4NDE2MDUsImV4cCI6MjA4OTQxNzYwNX0.zWyTVyYSwWk_JI6Lr9ycj2eJvb-WfmlOmcLjppVCiEA"

    static let client = SupabaseClient(
        supabaseURL: url,
        supabaseKey: anonKey
    )
}
