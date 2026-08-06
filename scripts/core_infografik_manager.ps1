[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [ValidateSet('snapshot', 'init-state', 'activate-manager', 'pause-manager', 'harvest-results', 'reserve-next', 'complete-core', 'block-manager', 'release-lock')]
  [string]$Action,
  [string]$ProjectRoot = 'C:\Users\tscho\Desktop\Thors_Cores_v03',
  [string]$StatePath = 'C:\Users\tscho\.codex\automations\core-infografiken-erzeugen\state.json',
  [string]$MemoryPath = 'C:\Users\tscho\.codex\automations\core-infografiken-erzeugen\memory.md',
  [string]$Owner = 'core-infografiken-manager',
  [string]$Now,
  [string]$CoreName,
  [string]$SourceImagePath,
  [string]$Reason = '',
  [string]$ErrorClass = '',
  [string]$ErrorCode = '',
  [string]$ErrorMessage = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$Utf8NoBom = [System.Text.UTF8Encoding]::new($false)

function Read-Utf8Json {
  param([Parameter(Mandatory = $true)][string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) {
    return $null
  }
  $content = [System.IO.File]::ReadAllText($Path, $Utf8NoBom)
  if ([string]::IsNullOrWhiteSpace($content)) {
    return $null
  }
  return $content | ConvertFrom-Json
}

function Write-Utf8Json {
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $true)]$Value
  )
  $json = $Value | ConvertTo-Json -Depth 16
  [System.IO.File]::WriteAllText($Path, $json, $Utf8NoBom)
}

function Set-NoteProperty {
  param(
    [Parameter(Mandatory = $true)]$Object,
    [Parameter(Mandatory = $true)][string]$Name,
    [Parameter(Mandatory = $true)]$Value
  )
  if ($Object.PSObject.Properties[$Name]) {
    $Object.$Name = $Value
  } else {
    $Object | Add-Member -NotePropertyName $Name -NotePropertyValue $Value
  }
}

function Get-NowValue {
  param([string]$Value)
  if ([string]::IsNullOrWhiteSpace($Value)) {
    return [DateTimeOffset]::Now
  }
  return [DateTimeOffset]::Parse($Value, [System.Globalization.CultureInfo]::InvariantCulture)
}

function Get-CoreCatalog {
  param([Parameter(Mandatory = $true)][string]$Root)
  $data = Read-Utf8Json -Path (Join-Path $Root 'Cores.json')
  if ($null -eq $data) {
    throw 'Cores.json konnte nicht gelesen werden.'
  }
  $cores = if ($data.PSObject.Properties['cores']) { $data.cores } else { $data }
  $catalog = @()
  $index = 0
  foreach ($core in $cores) {
    $name = $null
    if ($core -is [string]) {
      $name = $core
    } elseif ($core.PSObject.Properties['title']) {
      $name = $core.title
    } elseif ($core.PSObject.Properties['name']) {
      $name = $core.name
    } elseif ($core.PSObject.Properties['short_title']) {
      $name = $core.short_title
    }
    if (-not [string]::IsNullOrWhiteSpace($name)) {
      $file = 'core.V01.{0}.png' -f $name
      $catalog += [pscustomobject]@{
        name = $name
        index = $index
        file = $file
        targetPath = Join-Path (Join-Path $Root 'Infografiken') $file
      }
    }
    $index++
  }
  return $catalog
}

function New-DefaultState {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][DateTimeOffset]$Timestamp
  )
  return [pscustomobject]@{
    schemaVersion = '2.0.0'
    automationId = 'core-infografiken-erzeugen'
    managerKind = 'cron_queue_manager_supported_variant'
    projectRoot = $Root
    outputDirectory = Join-Path $Root 'Infografiken'
    promptTemplate = 'Erstelle eine Infografik zu <Core-Name> im Dark Mode im 16:9-Querformat'
    status = 'PAUSED_MANAGER_READY'
    phase = 'manager_configured_waiting_activation'
    manualVerificationRequired = $false
    resumeAllowed = $false
    promptIntervalMinutes = 2
    lastPromptIssuedAt = $null
    lastHarvestAt = $null
    lastPromptEligibilityAt = $null
    selectedCore = $null
    nextSuggestedCore = $null
    lastSuccessfulCore = $null
    progress = [pscustomobject]@{
      promptSent = $false
      imageReady = $false
      fileVerified = $false
    }
    queue = [pscustomobject]@{
      pending = @()
      inflight = @()
      completed = @()
    }
    queueStats = [pscustomobject]@{
      pendingCount = 0
      inflightCount = 0
      completedCount = 0
    }
    runLock = [pscustomobject]@{
      active = $false
      owner = $null
      acquiredAt = $null
      staleAfterMinutes = 30
      lastReleasedAt = $Timestamp.ToString('o')
    }
    capabilities = [pscustomobject]@{
      persistentManagerSupported = $false
      persistentManagerReason = 'Der unterstuetzte Bildweg image_gen.imagegen ist nur innerhalb eines Codex-Laufs verfuegbar; die verfuegbare Automationsoberflaeche ist cron-basiert und bietet keinen separaten lokalen Daemon mit diesem Toolzugriff.'
      asyncSubmitPollSupported = $false
      asyncSubmitPollReason = 'Fuer image_gen.imagegen gibt es hier keinen unterstuetzten Submit-und-spaeter-Poll-Jobmodus. Ergebnisse liegen nur innerhalb desselben Codex-Laufs vor.'
      supportedVariant = 'Queue-und-Rate-Limit-Manager ueber wiederkehrende Cron-Ticks mit persistentem Zustand'
    }
    directGenerationPolicy = [pscustomobject]@{
      tool = 'image_gen.imagegen'
      allowBrowserPath = $false
      allowNodeReplPath = $false
      overwriteAllowed = $false
      requireFileVerification = $true
      requireDarkModeCheck = $true
      requireAspectRatioCheck = $true
    }
    serialRunPolicy = [pscustomobject]@{
      maxPromptSubmissionsPerInterval = 1
      promptIntervalMinutes = 2
      allowParallelWorkers = $false
      maxConcurrentRuns = 1
      allowMultipleInflightQueueEntries = $true
      actualAsyncInflightGenerationSupported = $false
    }
    imageRequirements = [pscustomobject]@{
      mode = 'dark'
      orientation = 'landscape'
      aspectRatio = '16:9'
      applyByDefault = $true
      tolerance = 0.05
      darkLuminanceThreshold = 72
    }
    pauseReason = [pscustomobject]@{
      class = 'MANUAL_PAUSE'
      code = 'NOT_ACTIVATED'
      message = 'Manager ist konfiguriert, aber noch nicht aktiviert.'
      firstObservedAt = $Timestamp.ToString('o')
      lastObservedAt = $Timestamp.ToString('o')
    }
    notificationStatus = 'ready'
  }
}

function Ensure-StateShape {
  param(
    [Parameter(Mandatory = $true)]$State,
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][DateTimeOffset]$Timestamp
  )
  $defaultState = New-DefaultState -Root $Root -Timestamp $Timestamp
  foreach ($property in $defaultState.PSObject.Properties.Name) {
    if (-not $State.PSObject.Properties[$property]) {
      Set-NoteProperty -Object $State -Name $property -Value $defaultState.$property
    }
  }
  Set-NoteProperty -Object $State -Name 'schemaVersion' -Value '2.0.0'
  Set-NoteProperty -Object $State -Name 'managerKind' -Value 'cron_queue_manager_supported_variant'
  Set-NoteProperty -Object $State -Name 'projectRoot' -Value $Root
  Set-NoteProperty -Object $State -Name 'outputDirectory' -Value (Join-Path $Root 'Infografiken')
  Set-NoteProperty -Object $State -Name 'promptTemplate' -Value 'Erstelle eine Infografik zu <Core-Name> im Dark Mode im 16:9-Querformat'
  Set-NoteProperty -Object $State -Name 'promptIntervalMinutes' -Value 2

  if (-not $State.PSObject.Properties['queue'] -or $null -eq $State.queue) {
    Set-NoteProperty -Object $State -Name 'queue' -Value $defaultState.queue
  }
  if (-not $State.queue.PSObject.Properties['pending']) {
    Set-NoteProperty -Object $State.queue -Name 'pending' -Value @()
  }
  if (-not $State.queue.PSObject.Properties['inflight']) {
    Set-NoteProperty -Object $State.queue -Name 'inflight' -Value @()
  }
  if (-not $State.queue.PSObject.Properties['completed']) {
    Set-NoteProperty -Object $State.queue -Name 'completed' -Value @()
  }

  foreach ($compoundName in 'queueStats', 'runLock', 'capabilities', 'directGenerationPolicy', 'serialRunPolicy', 'imageRequirements', 'pauseReason', 'progress') {
    if (-not $State.PSObject.Properties[$compoundName] -or $null -eq $State.$compoundName) {
      Set-NoteProperty -Object $State -Name $compoundName -Value $defaultState.$compoundName
    }
  }

  Set-NoteProperty -Object $State.capabilities -Name 'persistentManagerSupported' -Value $false
  Set-NoteProperty -Object $State.capabilities -Name 'persistentManagerReason' -Value $defaultState.capabilities.persistentManagerReason
  Set-NoteProperty -Object $State.capabilities -Name 'asyncSubmitPollSupported' -Value $false
  Set-NoteProperty -Object $State.capabilities -Name 'asyncSubmitPollReason' -Value $defaultState.capabilities.asyncSubmitPollReason
  Set-NoteProperty -Object $State.capabilities -Name 'supportedVariant' -Value $defaultState.capabilities.supportedVariant

  Set-NoteProperty -Object $State.serialRunPolicy -Name 'maxPromptSubmissionsPerInterval' -Value 1
  Set-NoteProperty -Object $State.serialRunPolicy -Name 'promptIntervalMinutes' -Value 2
  Set-NoteProperty -Object $State.serialRunPolicy -Name 'allowParallelWorkers' -Value $false
  Set-NoteProperty -Object $State.serialRunPolicy -Name 'maxConcurrentRuns' -Value 1
  Set-NoteProperty -Object $State.serialRunPolicy -Name 'allowMultipleInflightQueueEntries' -Value $true
  Set-NoteProperty -Object $State.serialRunPolicy -Name 'actualAsyncInflightGenerationSupported' -Value $false

  Set-NoteProperty -Object $State.directGenerationPolicy -Name 'tool' -Value 'image_gen.imagegen'
  Set-NoteProperty -Object $State.directGenerationPolicy -Name 'allowBrowserPath' -Value $false
  Set-NoteProperty -Object $State.directGenerationPolicy -Name 'allowNodeReplPath' -Value $false
  Set-NoteProperty -Object $State.directGenerationPolicy -Name 'overwriteAllowed' -Value $false
  Set-NoteProperty -Object $State.directGenerationPolicy -Name 'requireFileVerification' -Value $true
  Set-NoteProperty -Object $State.directGenerationPolicy -Name 'requireDarkModeCheck' -Value $true
  Set-NoteProperty -Object $State.directGenerationPolicy -Name 'requireAspectRatioCheck' -Value $true

  Set-NoteProperty -Object $State.imageRequirements -Name 'mode' -Value 'dark'
  Set-NoteProperty -Object $State.imageRequirements -Name 'orientation' -Value 'landscape'
  Set-NoteProperty -Object $State.imageRequirements -Name 'aspectRatio' -Value '16:9'
  Set-NoteProperty -Object $State.imageRequirements -Name 'applyByDefault' -Value $true
  Set-NoteProperty -Object $State.imageRequirements -Name 'tolerance' -Value 0.05
  Set-NoteProperty -Object $State.imageRequirements -Name 'darkLuminanceThreshold' -Value 72

  Set-NoteProperty -Object $State.runLock -Name 'staleAfterMinutes' -Value 30
  if (-not $State.PSObject.Properties['notificationStatus']) {
    Set-NoteProperty -Object $State -Name 'notificationStatus' -Value 'ready'
  }
}

function Get-ImageVerification {
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [double]$AspectTolerance = 0.05,
    [double]$DarkThreshold = 72
  )
  if (-not (Test-Path -LiteralPath $Path)) {
    return [pscustomobject]@{
      exists = $false
      valid = $false
      width = 0
      height = 0
      aspectRatio = 0
      approx16By9 = $false
      isLandscape = $false
      averageLuminance0to255 = $null
      darkThemeIndicative = $false
      sampledPixels = 0
      length = 0
    }
  }

  $file = Get-Item -LiteralPath $Path
  $image = [System.Drawing.Image]::FromFile($Path)
  try {
    $bitmap = [System.Drawing.Bitmap]::new($image)
    try {
      $columns = 18
      $rows = 20
      $sum = 0.0
      $samples = 0
      for ($column = 0; $column -lt $columns; $column++) {
        for ($row = 0; $row -lt $rows; $row++) {
          $x = [int][Math]::Min($bitmap.Width - 1, [Math]::Floor((($column + 0.5) * $bitmap.Width) / $columns))
          $y = [int][Math]::Min($bitmap.Height - 1, [Math]::Floor((($row + 0.5) * $bitmap.Height) / $rows))
          $pixel = $bitmap.GetPixel($x, $y)
          $sum += (0.2126 * $pixel.R) + (0.7152 * $pixel.G) + (0.0722 * $pixel.B)
          $samples++
        }
      }
      $average = if ($samples -gt 0) { [Math]::Round(($sum / $samples), 2) } else { $null }
      $ratio = if ($bitmap.Height -gt 0) { [Math]::Round(($bitmap.Width / $bitmap.Height), 4) } else { 0 }
      $approx = [Math]::Abs($ratio - (16.0 / 9.0)) -le $AspectTolerance
      $landscape = $bitmap.Width -gt $bitmap.Height
      $dark = $null -ne $average -and $average -le $DarkThreshold
      return [pscustomobject]@{
        exists = $true
        valid = ($landscape -and $approx -and $dark)
        width = $bitmap.Width
        height = $bitmap.Height
        aspectRatio = $ratio
        approx16By9 = $approx
        isLandscape = $landscape
        averageLuminance0to255 = $average
        darkThemeIndicative = $dark
        sampledPixels = $samples
        length = $file.Length
      }
    } finally {
      $bitmap.Dispose()
    }
  } finally {
    $image.Dispose()
  }
}

function Refresh-Queue {
  param(
    [Parameter(Mandatory = $true)]$State,
    [Parameter(Mandatory = $true)]$Catalog,
    [Parameter(Mandatory = $true)][DateTimeOffset]$Timestamp
  )

  $existingCompletedMap = @{}
  foreach ($entry in @($State.queue.completed)) {
    if ($null -ne $entry -and -not [string]::IsNullOrWhiteSpace([string]$entry.name)) {
      $existingCompletedMap[[string]$entry.name] = $entry
    }
  }

  $stillInflight = @()
  $harvested = @()
  foreach ($entry in @($State.queue.inflight)) {
    if ($null -eq $entry -or [string]::IsNullOrWhiteSpace([string]$entry.name)) {
      continue
    }
    if (Test-Path -LiteralPath $entry.targetPath) {
      $verification = Get-ImageVerification -Path $entry.targetPath -AspectTolerance $State.imageRequirements.tolerance -DarkThreshold $State.imageRequirements.darkLuminanceThreshold
      if (-not $verification.valid) {
        return [pscustomobject]@{
          ok = $false
          harvested = @()
          validationFailure = [pscustomobject]@{
            name = $entry.name
            targetPath = $entry.targetPath
            verification = $verification
          }
        }
      }
      $completedEntry = [pscustomobject]@{
        name = $entry.name
        index = $entry.index
        file = $entry.file
        targetPath = $entry.targetPath
        promptIssuedAt = $entry.promptIssuedAt
        completedAt = $Timestamp.ToString('o')
        harvested = $true
        verification = $verification
      }
      $existingCompletedMap[[string]$entry.name] = $completedEntry
      $harvested += $completedEntry
    } else {
      $stillInflight += $entry
    }
  }

  foreach ($catalogEntry in $Catalog) {
    if ((Test-Path -LiteralPath $catalogEntry.targetPath) -and -not $existingCompletedMap.ContainsKey([string]$catalogEntry.name)) {
      $existingCompletedMap[[string]$catalogEntry.name] = [pscustomobject]@{
        name = $catalogEntry.name
        index = $catalogEntry.index
        file = $catalogEntry.file
        targetPath = $catalogEntry.targetPath
        promptIssuedAt = $null
        completedAt = $Timestamp.ToString('o')
        harvested = $false
        verification = $null
      }
    }
  }

  $completed = @($Catalog | Where-Object { $existingCompletedMap.ContainsKey([string]$_.name) } | ForEach-Object { $existingCompletedMap[[string]$_.name] })
  $inflightNames = @{}
  foreach ($entry in $stillInflight) {
    $inflightNames[[string]$entry.name] = $true
  }
  $completedNames = @{}
  foreach ($entry in $completed) {
    $completedNames[[string]$entry.name] = $true
  }

  $pending = @($Catalog | Where-Object { (-not $completedNames.ContainsKey([string]$_.name)) -and (-not $inflightNames.ContainsKey([string]$_.name)) })

  $State.queue.pending = $pending
  $State.queue.inflight = $stillInflight
  $State.queue.completed = $completed
  $State.queueStats.pendingCount = @($pending).Count
  $State.queueStats.inflightCount = @($stillInflight).Count
  $State.queueStats.completedCount = @($completed).Count
  $State.nextSuggestedCore = if (@($pending).Count -gt 0) { $pending[0] } else { $null }
  if (@($stillInflight).Count -gt 0) {
    $State.selectedCore = $stillInflight[0]
  } elseif (@($pending).Count -gt 0) {
    $State.selectedCore = $pending[0]
  } else {
    $State.selectedCore = $null
  }
  $State.lastHarvestAt = $Timestamp.ToString('o')

  return [pscustomobject]@{
    ok = $true
    harvested = $harvested
    validationFailure = $null
  }
}

function Release-LockInternal {
  param(
    [Parameter(Mandatory = $true)]$State,
    [Parameter(Mandatory = $true)][DateTimeOffset]$Timestamp
  )
  $State.runLock.active = $false
  $State.runLock.owner = $null
  $State.runLock.acquiredAt = $null
  $State.runLock.lastReleasedAt = $Timestamp.ToString('o')
}

function Set-BlockedState {
  param(
    [Parameter(Mandatory = $true)]$State,
    [Parameter(Mandatory = $true)][DateTimeOffset]$Timestamp,
    [Parameter(Mandatory = $true)][string]$Class,
    [Parameter(Mandatory = $true)][string]$Code,
    [Parameter(Mandatory = $true)][string]$Message
  )
  $State.status = 'PAUSED_BLOCKED'
  $State.phase = 'blocked'
  $State.resumeAllowed = $false
  $State.manualVerificationRequired = $true
  $State.pauseReason = [pscustomobject]@{
    class = $Class
    code = $Code
    message = $Message
    firstObservedAt = if ($State.pauseReason -and $State.pauseReason.firstObservedAt) { $State.pauseReason.firstObservedAt } else { $Timestamp.ToString('o') }
    lastObservedAt = $Timestamp.ToString('o')
  }
  Release-LockInternal -State $State -Timestamp $Timestamp
}

function Write-MemorySummary {
  param(
    [Parameter(Mandatory = $true)]$State,
    [Parameter(Mandatory = $true)][string]$Path
  )
  $pendingLine = if (@($State.queue.pending).Count -gt 0) { ($State.queue.pending | Select-Object -First 5 -ExpandProperty name) -join ', ' } else { '(leer)' }
  $inflightLine = if (@($State.queue.inflight).Count -gt 0) { ($State.queue.inflight | Select-Object -ExpandProperty name) -join ', ' } else { '(leer)' }
  $completedCount = @($State.queue.completed).Count
  $nextEligible = if ($State.lastPromptIssuedAt) { ([DateTimeOffset]::Parse($State.lastPromptIssuedAt)).AddMinutes([int]$State.promptIntervalMinutes).ToString('o') } else { 'sofort' }
  $lastSuccess = if ($State.lastSuccessfulCore) { $State.lastSuccessfulCore.name } else { '(keiner)' }
  $selected = if ($State.selectedCore) { $State.selectedCore.name } else { '(keiner)' }
  $content = @"
# Core-Infografiken - Queue-Manager

- status: $($State.status)
- phase: $($State.phase)
- resume_allowed: $($State.resumeAllowed)
- manual_verification_required: $($State.manualVerificationRequired)
- manager_kind: $($State.managerKind)
- supported_variant: $($State.capabilities.supportedVariant)
- persistent_manager_supported: $($State.capabilities.persistentManagerSupported)
- async_submit_poll_supported: $($State.capabilities.asyncSubmitPollSupported)
- prompt_interval_minutes: $($State.promptIntervalMinutes)
- last_prompt_issued_at: $($State.lastPromptIssuedAt)
- next_prompt_eligible_at: $nextEligible
- selected_core: $selected
- next_suggested_core: $(if ($State.nextSuggestedCore) { $State.nextSuggestedCore.name } else { '(keiner)' })
- pending_count: $(@($State.queue.pending).Count)
- inflight_count: $(@($State.queue.inflight).Count)
- completed_count: $completedCount
- pending_preview: $pendingLine
- inflight_preview: $inflightLine
- last_successful_core: $lastSuccess
- output_directory: $($State.outputDirectory)
- image_requirements: dark / 16:9 / landscape / no-overwrite / file verification required
- pause_reason_class: $($State.pauseReason.class)
- pause_reason_code: $($State.pauseReason.code)
- pause_reason_message: $($State.pauseReason.message)
- run_lock_active: $($State.runLock.active)
- run_lock_owner: $($State.runLock.owner)
- run_lock_acquired_at: $($State.runLock.acquiredAt)
- run_lock_last_released_at: $($State.runLock.lastReleasedAt)

## Limits

- Direkter Bildweg bleibt image_gen.imagegen.
- Kein Browser- oder node_repl-Pfad.
- Kein unterstuetzter externer Submit-und-spaeter-Poll-Mechanismus vorhanden.
- Deshalb ist dies eine cron-basierte Queue-Manager-Variante und kein separater lokaler Daemon mit echtem Parallel-Inflight-Submit.
"@
  [System.IO.File]::WriteAllText($Path, $content, $Utf8NoBom)
}

function Save-State {
  param(
    [Parameter(Mandatory = $true)]$State,
    [Parameter(Mandatory = $true)][string]$JsonPath,
    [Parameter(Mandatory = $true)][string]$SummaryPath
  )
  Write-Utf8Json -Path $JsonPath -Value $State
  Write-MemorySummary -State $State -Path $SummaryPath
}

function Get-State {
  param(
    [Parameter(Mandatory = $true)][string]$JsonPath,
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][DateTimeOffset]$Timestamp
  )
  $state = Read-Utf8Json -Path $JsonPath
  if ($null -eq $state) {
    $state = New-DefaultState -Root $Root -Timestamp $Timestamp
  }
  Ensure-StateShape -State $state -Root $Root -Timestamp $Timestamp
  return $state
}

$timestamp = Get-NowValue -Value $Now
$catalog = Get-CoreCatalog -Root $ProjectRoot
$state = Get-State -JsonPath $StatePath -Root $ProjectRoot -Timestamp $timestamp
$refresh = Refresh-Queue -State $state -Catalog $catalog -Timestamp $timestamp
if (-not $refresh.ok) {
  Set-BlockedState -State $state -Timestamp $timestamp -Class 'VALIDATION_BLOCKER' -Code 'HARVESTED_FILE_INVALID' -Message ('Gefundene Rueckgabedatei fuer {0} verfehlt Datei-, 16:9- oder Dark-Mode-Pruefung.' -f $refresh.validationFailure.name)
  Save-State -State $state -JsonPath $StatePath -SummaryPath $MemoryPath
  [pscustomobject]@{
    action = 'blocked'
    status = $state.status
    errorClass = 'VALIDATION_BLOCKER'
    errorCode = 'HARVESTED_FILE_INVALID'
    targetPath = $refresh.validationFailure.targetPath
    verification = $refresh.validationFailure.verification
  } | ConvertTo-Json -Depth 16
  exit 0
}

switch ($Action) {
  'init-state' {
    if ($state.status -eq 'ACTIVE_READY') {
      $state.status = 'PAUSED_MANAGER_READY'
      $state.resumeAllowed = $false
    }
    $state.phase = 'manager_state_initialized'
    $state.pauseReason = [pscustomobject]@{
      class = 'MANUAL_PAUSE'
      code = 'MANAGER_INIT_COMPLETE'
      message = 'Queue-Manager-Zustand initialisiert; Aktivierung getrennt vornehmen.'
      firstObservedAt = if ($state.pauseReason -and $state.pauseReason.firstObservedAt) { $state.pauseReason.firstObservedAt } else { $timestamp.ToString('o') }
      lastObservedAt = $timestamp.ToString('o')
    }
    Save-State -State $state -JsonPath $StatePath -SummaryPath $MemoryPath
    [pscustomobject]@{
      action = 'initialized'
      status = $state.status
      pendingCount = $state.queueStats.pendingCount
      inflightCount = $state.queueStats.inflightCount
      completedCount = $state.queueStats.completedCount
      nextSuggestedCore = $state.nextSuggestedCore
    } | ConvertTo-Json -Depth 16
  }
  'activate-manager' {
    $state.status = 'ACTIVE_MANAGER_READY'
    $state.phase = 'active_queue_manager_ready'
    $state.resumeAllowed = $true
    $state.manualVerificationRequired = $false
    $state.pauseReason = [pscustomobject]@{
      class = 'NONE'
      code = 'ACTIVE_QUEUE_MANAGER_READY'
      message = 'Die getestete Queue-und-Rate-Limit-Variante ist aktiviert.'
      firstObservedAt = if ($state.pauseReason -and $state.pauseReason.firstObservedAt) { $state.pauseReason.firstObservedAt } else { $timestamp.ToString('o') }
      lastObservedAt = $timestamp.ToString('o')
    }
    Save-State -State $state -JsonPath $StatePath -SummaryPath $MemoryPath
    [pscustomobject]@{
      action = 'activated'
      status = $state.status
      nextSuggestedCore = $state.nextSuggestedCore
      nextPromptEligibleAt = if ($state.lastPromptIssuedAt) { ([DateTimeOffset]::Parse($state.lastPromptIssuedAt)).AddMinutes([int]$state.promptIntervalMinutes).ToString('o') } else { $timestamp.ToString('o') }
      capabilities = $state.capabilities
    } | ConvertTo-Json -Depth 16
  }
  'pause-manager' {
    $state.status = 'PAUSED_MANAGER_READY'
    $state.phase = 'manager_paused'
    $state.resumeAllowed = $false
    $state.manualVerificationRequired = $false
    $state.pauseReason = [pscustomobject]@{
      class = 'MANUAL_PAUSE'
      code = if ([string]::IsNullOrWhiteSpace($Reason)) { 'MANUAL_PAUSE' } else { 'MANUAL_PAUSE_WITH_REASON' }
      message = if ([string]::IsNullOrWhiteSpace($Reason)) { 'Manager wurde manuell pausiert.' } else { $Reason }
      firstObservedAt = if ($state.pauseReason -and $state.pauseReason.firstObservedAt) { $state.pauseReason.firstObservedAt } else { $timestamp.ToString('o') }
      lastObservedAt = $timestamp.ToString('o')
    }
    Release-LockInternal -State $state -Timestamp $timestamp
    Save-State -State $state -JsonPath $StatePath -SummaryPath $MemoryPath
    [pscustomobject]@{
      action = 'paused'
      status = $state.status
      reason = $state.pauseReason.message
    } | ConvertTo-Json -Depth 16
  }
  'harvest-results' {
    Save-State -State $state -JsonPath $StatePath -SummaryPath $MemoryPath
    [pscustomobject]@{
      action = 'harvested'
      harvestedCount = @($refresh.harvested).Count
      harvested = $refresh.harvested
      pendingCount = $state.queueStats.pendingCount
      inflightCount = $state.queueStats.inflightCount
      completedCount = $state.queueStats.completedCount
    } | ConvertTo-Json -Depth 16
  }
  'reserve-next' {
    if ($state.status -ne 'ACTIVE_MANAGER_READY' -or -not $state.resumeAllowed -or $state.manualVerificationRequired) {
      Save-State -State $state -JsonPath $StatePath -SummaryPath $MemoryPath
      [pscustomobject]@{
        action = 'paused_state'
        status = $state.status
        resumeAllowed = $state.resumeAllowed
        manualVerificationRequired = $state.manualVerificationRequired
      } | ConvertTo-Json -Depth 16
      break
    }

    if ($state.runLock.active) {
      $acquiredAt = if ($state.runLock.acquiredAt) { [DateTimeOffset]::Parse($state.runLock.acquiredAt) } else { $timestamp }
      $staleAt = $acquiredAt.AddMinutes([int]$state.runLock.staleAfterMinutes)
      if ($timestamp -lt $staleAt) {
        Save-State -State $state -JsonPath $StatePath -SummaryPath $MemoryPath
        [pscustomobject]@{
          action = 'wait_lock'
          status = $state.status
          lockOwner = $state.runLock.owner
          lockAcquiredAt = $state.runLock.acquiredAt
          staleAt = $staleAt.ToString('o')
        } | ConvertTo-Json -Depth 16
        break
      }
      Set-BlockedState -State $state -Timestamp $timestamp -Class 'RUN_LOCK_BLOCKER' -Code 'STALE_RUN_LOCK' -Message 'Der serielle Manager-Lock ist stale und erfordert manuelle Kontrolle.'
      Save-State -State $state -JsonPath $StatePath -SummaryPath $MemoryPath
      [pscustomobject]@{
        action = 'blocked'
        status = $state.status
        errorClass = 'RUN_LOCK_BLOCKER'
        errorCode = 'STALE_RUN_LOCK'
      } | ConvertTo-Json -Depth 16
      break
    }

    if (@($state.queue.pending).Count -eq 0) {
      Save-State -State $state -JsonPath $StatePath -SummaryPath $MemoryPath
      [pscustomobject]@{
        action = 'idle_no_pending'
        status = $state.status
        inflightCount = $state.queueStats.inflightCount
        completedCount = $state.queueStats.completedCount
      } | ConvertTo-Json -Depth 16
      break
    }

    if ($state.lastPromptIssuedAt) {
      $nextAllowed = ([DateTimeOffset]::Parse($state.lastPromptIssuedAt)).AddMinutes([int]$state.promptIntervalMinutes)
      $state.lastPromptEligibilityAt = $nextAllowed.ToString('o')
      if ($timestamp -lt $nextAllowed) {
        Save-State -State $state -JsonPath $StatePath -SummaryPath $MemoryPath
        [pscustomobject]@{
          action = 'wait_rate_limit'
          status = $state.status
          lastPromptIssuedAt = $state.lastPromptIssuedAt
          nextPromptEligibleAt = $nextAllowed.ToString('o')
          pendingCount = $state.queueStats.pendingCount
          inflightCount = $state.queueStats.inflightCount
        } | ConvertTo-Json -Depth 16
        break
      }
    }

    $nextCore = $state.queue.pending[0]
    $state.runLock.active = $true
    $state.runLock.owner = $Owner
    $state.runLock.acquiredAt = $timestamp.ToString('o')
    $state.lastPromptIssuedAt = $timestamp.ToString('o')
    $state.lastPromptEligibilityAt = $timestamp.AddMinutes([int]$state.promptIntervalMinutes).ToString('o')
    $state.phase = 'prompt_reserved'
    $state.progress.promptSent = $false
    $state.progress.imageReady = $false
    $state.progress.fileVerified = $false

    $inflightEntry = [pscustomobject]@{
      name = $nextCore.name
      index = $nextCore.index
      file = $nextCore.file
      targetPath = $nextCore.targetPath
      promptIssuedAt = $timestamp.ToString('o')
      status = 'reserved_for_direct_generation'
      prompt = ('Erstelle eine Infografik zu {0} im Dark Mode im 16:9-Querformat' -f $nextCore.name)
      owner = $Owner
    }
    $state.queue.pending = @($state.queue.pending | Select-Object -Skip 1)
    $state.queue.inflight = @($state.queue.inflight + $inflightEntry)
    $state.queueStats.pendingCount = @($state.queue.pending).Count
    $state.queueStats.inflightCount = @($state.queue.inflight).Count
    $state.selectedCore = $inflightEntry
    Save-State -State $state -JsonPath $StatePath -SummaryPath $MemoryPath

    [pscustomobject]@{
      action = 'issue_prompt'
      status = $state.status
      core = $inflightEntry
      prompt = $inflightEntry.prompt
      nextPromptEligibleAt = $state.lastPromptEligibilityAt
      pendingCount = $state.queueStats.pendingCount
      inflightCount = $state.queueStats.inflightCount
    } | ConvertTo-Json -Depth 16
  }
  'complete-core' {
    if ([string]::IsNullOrWhiteSpace($CoreName)) {
      throw 'Fuer complete-core ist -CoreName erforderlich.'
    }
    $targetEntry = @($state.queue.inflight | Where-Object { $_.name -eq $CoreName } | Select-Object -First 1)
    if (-not $targetEntry) {
      throw ('Es gibt keinen inflight-Eintrag fuer {0}.' -f $CoreName)
    }
    if (-not [string]::IsNullOrWhiteSpace($SourceImagePath)) {
      if (-not (Test-Path -LiteralPath $SourceImagePath)) {
        Set-BlockedState -State $state -Timestamp $timestamp -Class 'DIRECT_GENERATION_BLOCKER' -Code 'SOURCE_IMAGE_MISSING' -Message ('Das erzeugte Bild fuer {0} konnte lokal nicht gefunden werden.' -f $CoreName)
        Save-State -State $state -JsonPath $StatePath -SummaryPath $MemoryPath
        [pscustomobject]@{ action = 'blocked'; status = $state.status; errorClass = 'DIRECT_GENERATION_BLOCKER'; errorCode = 'SOURCE_IMAGE_MISSING' } | ConvertTo-Json -Depth 16
        break
      }
      if (Test-Path -LiteralPath $targetEntry.targetPath) {
        Set-BlockedState -State $state -Timestamp $timestamp -Class 'OUTPUT_FILE_BLOCKER' -Code 'TARGET_ALREADY_EXISTS' -Message ('Die Zieldatei fuer {0} existiert bereits und darf nicht ueberschrieben werden.' -f $CoreName)
        Save-State -State $state -JsonPath $StatePath -SummaryPath $MemoryPath
        [pscustomobject]@{ action = 'blocked'; status = $state.status; errorClass = 'OUTPUT_FILE_BLOCKER'; errorCode = 'TARGET_ALREADY_EXISTS' } | ConvertTo-Json -Depth 16
        break
      }
      Copy-Item -LiteralPath $SourceImagePath -Destination $targetEntry.targetPath -Force:$false
    }

    $verification = Get-ImageVerification -Path $targetEntry.targetPath -AspectTolerance $state.imageRequirements.tolerance -DarkThreshold $state.imageRequirements.darkLuminanceThreshold
    if (-not $verification.valid) {
      Set-BlockedState -State $state -Timestamp $timestamp -Class 'VALIDATION_BLOCKER' -Code 'TARGET_FILE_INVALID' -Message ('Die Zieldatei fuer {0} erfuellt Dark-Mode-, 16:9- oder Querformat-Pruefung nicht.' -f $CoreName)
      Save-State -State $state -JsonPath $StatePath -SummaryPath $MemoryPath
      [pscustomobject]@{ action = 'blocked'; status = $state.status; errorClass = 'VALIDATION_BLOCKER'; errorCode = 'TARGET_FILE_INVALID'; verification = $verification } | ConvertTo-Json -Depth 16
      break
    }

    $completedEntry = [pscustomobject]@{
      name = $targetEntry.name
      index = $targetEntry.index
      file = $targetEntry.file
      targetPath = $targetEntry.targetPath
      promptIssuedAt = $targetEntry.promptIssuedAt
      completedAt = $timestamp.ToString('o')
      harvested = $false
      verification = $verification
    }
    $state.queue.inflight = @($state.queue.inflight | Where-Object { $_.name -ne $CoreName })
    $state.queue.completed = @($state.queue.completed | Where-Object { $_.name -ne $CoreName }) + $completedEntry
    $state.queueStats.inflightCount = @($state.queue.inflight).Count
    $state.queueStats.completedCount = @($state.queue.completed).Count
    $state.lastSuccessfulCore = [pscustomobject]@{
      name = $completedEntry.name
      index = $completedEntry.index
      file = $completedEntry.file
      fullPath = $completedEntry.targetPath
      verifiedAt = $timestamp.ToString('o')
      verification = $verification
    }
    $state.phase = 'direct_generation_completed'
    $state.progress.promptSent = $true
    $state.progress.imageReady = $true
    $state.progress.fileVerified = $true
    $state.selectedCore = if (@($state.queue.inflight).Count -gt 0) { $state.queue.inflight[0] } elseif (@($state.queue.pending).Count -gt 0) { $state.queue.pending[0] } else { $null }
    $state.nextSuggestedCore = if (@($state.queue.pending).Count -gt 0) { $state.queue.pending[0] } else { $null }
    Release-LockInternal -State $state -Timestamp $timestamp
    Save-State -State $state -JsonPath $StatePath -SummaryPath $MemoryPath

    [pscustomobject]@{
      action = 'completed'
      status = $state.status
      completed = $completedEntry
      nextSuggestedCore = $state.nextSuggestedCore
      queueStats = $state.queueStats
    } | ConvertTo-Json -Depth 16
  }
  'block-manager' {
    if ([string]::IsNullOrWhiteSpace($ErrorClass) -or [string]::IsNullOrWhiteSpace($ErrorCode) -or [string]::IsNullOrWhiteSpace($ErrorMessage)) {
      throw 'Fuer block-manager sind -ErrorClass, -ErrorCode und -ErrorMessage erforderlich.'
    }
    Set-BlockedState -State $state -Timestamp $timestamp -Class $ErrorClass -Code $ErrorCode -Message $ErrorMessage
    Save-State -State $state -JsonPath $StatePath -SummaryPath $MemoryPath
    [pscustomobject]@{
      action = 'blocked'
      status = $state.status
      errorClass = $ErrorClass
      errorCode = $ErrorCode
      errorMessage = $ErrorMessage
    } | ConvertTo-Json -Depth 16
  }
  'release-lock' {
    Release-LockInternal -State $state -Timestamp $timestamp
    Save-State -State $state -JsonPath $StatePath -SummaryPath $MemoryPath
    [pscustomobject]@{
      action = 'lock_released'
      status = $state.status
      lastReleasedAt = $state.runLock.lastReleasedAt
    } | ConvertTo-Json -Depth 16
  }
  'snapshot' {
    Save-State -State $state -JsonPath $StatePath -SummaryPath $MemoryPath
    [pscustomobject]@{
      action = 'snapshot'
      status = $state.status
      phase = $state.phase
      capabilities = $state.capabilities
      queueStats = $state.queueStats
      nextSuggestedCore = $state.nextSuggestedCore
      lastPromptIssuedAt = $state.lastPromptIssuedAt
      nextPromptEligibleAt = if ($state.lastPromptIssuedAt) { ([DateTimeOffset]::Parse($state.lastPromptIssuedAt)).AddMinutes([int]$state.promptIntervalMinutes).ToString('o') } else { $timestamp.ToString('o') }
      runLock = $state.runLock
    } | ConvertTo-Json -Depth 16
  }
}
