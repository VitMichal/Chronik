//
//  Supabase.swift
//  Chronik
//
//  Created by Vít Míchal on 22.07.2026.
//

import Foundation
import Supabase

let supabaseClient = SupabaseClient(
  supabaseURL: URL(string: "https://xzkusiiimblfydndgsrl.supabase.co")!,
  supabaseKey: "sb_publishable_TjBN_kD2TMoATkw2INZNwg_hqf4TrPs",
  options: .init(
          auth: .init(
              emitLocalSessionAsInitialSession: true
          )
      )
)
